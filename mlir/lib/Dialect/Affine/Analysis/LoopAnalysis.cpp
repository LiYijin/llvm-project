//===- LoopAnalysis.cpp - Misc loop analysis routines //-------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements miscellaneous loop analysis routines.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"

#include "mlir/Analysis/SliceAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/AffineStructures.h"
#include "mlir/Dialect/Affine/Analysis/NestedMatcher.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/Support/MathExtras.h"

#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallString.h"
#include <numeric>
#include <optional>
#include <type_traits>

using namespace mlir;
using namespace mlir::affine;

/// Returns the trip count of the loop as an affine expression if the latter is
/// expressible as an affine expression, and nullptr otherwise. The trip count
/// expression is simplified before returning. This method only utilizes map
/// composition to construct lower and upper bounds before computing the trip
/// count expressions.
void mlir::affine::getTripCountMapAndOperands(
    AffineForOp forOp, AffineMap *tripCountMap,
    SmallVectorImpl<Value> *tripCountOperands) {
  MLIRContext *context = forOp.getContext();
  int64_t step = forOp.getStep();
  int64_t loopSpan;
  if (forOp.hasConstantBounds()) {
    int64_t lb = forOp.getConstantLowerBound();
    int64_t ub = forOp.getConstantUpperBound();
    loopSpan = ub - lb;
    if (loopSpan < 0)
      loopSpan = 0;
    *tripCountMap = AffineMap::getConstantMap(ceilDiv(loopSpan, step), context);
    tripCountOperands->clear();
    return;
  }
  auto lbMap = forOp.getLowerBoundMap();
  auto ubMap = forOp.getUpperBoundMap();
  if (lbMap.getNumResults() != 1) {
    *tripCountMap = AffineMap();
    return;
  }

  // Difference of each upper bound expression from the single lower bound
  // expression (divided by the step) provides the expressions for the trip
  // count map.
  AffineValueMap ubValueMap(ubMap, forOp.getUpperBoundOperands());

  SmallVector<AffineExpr, 4> lbSplatExpr(ubValueMap.getNumResults(),
                                         lbMap.getResult(0));
  auto lbMapSplat = AffineMap::get(lbMap.getNumDims(), lbMap.getNumSymbols(),
                                   lbSplatExpr, context);
  AffineValueMap lbSplatValueMap(lbMapSplat, forOp.getLowerBoundOperands());

  AffineValueMap tripCountValueMap;
  AffineValueMap::difference(ubValueMap, lbSplatValueMap, &tripCountValueMap);
  for (unsigned i = 0, e = tripCountValueMap.getNumResults(); i < e; ++i)
    tripCountValueMap.setResult(i,
                                tripCountValueMap.getResult(i).ceilDiv(step));

  *tripCountMap = tripCountValueMap.getAffineMap();
  tripCountOperands->assign(tripCountValueMap.getOperands().begin(),
                            tripCountValueMap.getOperands().end());
}

/// Returns the trip count of the loop if it's a constant, std::nullopt
/// otherwise. This method uses affine expression analysis (in turn using
/// getTripCount) and is able to determine constant trip count in non-trivial
/// cases.
std::optional<uint64_t> mlir::affine::getConstantTripCount(AffineForOp forOp) {
  SmallVector<Value, 4> operands;
  AffineMap map;
  getTripCountMapAndOperands(forOp, &map, &operands);

  if (!map)
    return std::nullopt;

  // Take the min if all trip counts are constant.
  std::optional<uint64_t> tripCount;
  for (auto resultExpr : map.getResults()) {
    if (auto constExpr = resultExpr.dyn_cast<AffineConstantExpr>()) {
      if (tripCount.has_value())
        tripCount =
            std::min(*tripCount, static_cast<uint64_t>(constExpr.getValue()));
      else
        tripCount = constExpr.getValue();
    } else
      return std::nullopt;
  }
  return tripCount;
}

/// Returns the greatest known integral divisor of the trip count. Affine
/// expression analysis is used (indirectly through getTripCount), and
/// this method is thus able to determine non-trivial divisors.
uint64_t mlir::affine::getLargestDivisorOfTripCount(AffineForOp forOp) {
  SmallVector<Value, 4> operands;
  AffineMap map;
  getTripCountMapAndOperands(forOp, &map, &operands);

  if (!map)
    return 1;

  // The largest divisor of the trip count is the GCD of the individual largest
  // divisors.
  assert(map.getNumResults() >= 1 && "expected one or more results");
  std::optional<uint64_t> gcd;
  for (auto resultExpr : map.getResults()) {
    uint64_t thisGcd;
    if (auto constExpr = resultExpr.dyn_cast<AffineConstantExpr>()) {
      uint64_t tripCount = constExpr.getValue();
      // 0 iteration loops (greatest divisor is 2^64 - 1).
      if (tripCount == 0)
        thisGcd = std::numeric_limits<uint64_t>::max();
      else
        // The greatest divisor is the trip count.
        thisGcd = tripCount;
    } else {
      // Trip count is not a known constant; return its largest known divisor.
      thisGcd = resultExpr.getLargestKnownDivisor();
    }
    if (gcd.has_value())
      gcd = std::gcd(*gcd, thisGcd);
    else
      gcd = thisGcd;
  }
  assert(gcd.has_value() && "value expected per above logic");
  return *gcd;
}

/// Given an induction variable `iv` of type AffineForOp and an access `index`
/// of type index, returns `true` if `index` is independent of `iv` and
/// false otherwise. The determination supports composition with at most one
/// AffineApplyOp. The 'at most one AffineApplyOp' comes from the fact that
/// the composition of AffineApplyOp needs to be canonicalized by construction
/// to avoid writing code that composes arbitrary numbers of AffineApplyOps
/// everywhere. To achieve this, at the very least, the compose-affine-apply
/// pass must have been run.
///
/// Prerequisites:
///   1. `iv` and `index` of the proper type;
///   2. at most one reachable AffineApplyOp from index;
///
/// Returns false in cases with more than one AffineApplyOp, this is
/// conservative.
static bool isAccessIndexInvariant(Value iv, Value index) {
  assert(isAffineForInductionVar(iv) && "iv must be a AffineForOp");
  assert(isa<IndexType>(index.getType()) && "index must be of IndexType");
  SmallVector<Operation *, 4> affineApplyOps;
  getReachableAffineApplyOps({index}, affineApplyOps);

  if (affineApplyOps.empty()) {
    // Pointer equality test because of Value pointer semantics.
    return index != iv;
  }

  if (affineApplyOps.size() > 1) {
    affineApplyOps[0]->emitRemark(
        "CompositionAffineMapsPass must have been run: there should be at most "
        "one AffineApplyOp, returning false conservatively.");
    return false;
  }

  auto composeOp = cast<AffineApplyOp>(affineApplyOps[0]);
  // We need yet another level of indirection because the `dim` index of the
  // access may not correspond to the `dim` index of composeOp.
  return !composeOp.getAffineValueMap().isFunctionOf(0, iv);
}

// // 我们猜测: 对最顶层的expr, 判断是否符合我们的要求:
// //   1. 最顶层由几个 add 组成
// //   2. 顶层的每个 subExpr 不包含add, 只由mul, mod, ceilDiv, floorDiv, dim,
// symbol, constant 组成 理论上, affineExpr可以分解表达成这种形式；
// 进一步推导出, 在每个乘除式中, 只可能有一个dimId, 其他都是常量或者symbolId.
// （因为规范要求, mul, mod, floorDiv, ceilDiv的右操作数不可能是dimId）

// 我们的猜测: 在遍历expr时, 除了 Add operator之外，对mul, mod,
// div等，RHS永远是单个的元素, 即: dimId, symbolId, constant,
// 而不会是一个表达式；其中, 因为规范不允许, 所以这些operator的RHS不可能是dimId,
// 所以在遍历expr时, RHS只可能是symbolId 或者 constant. 

// 猜测: `b` should only be changed in `Add` process. mul, div等操作, 不改变`b`的值.

static void initSymbolIdPattern(AccessPattern &resultAccessPattern) {
  // 对symbol作默认处理, 因为还没遇到对应的case
  // auto symExpr = expr.cast<AffineSymbolExpr>();
  // unsigned position = symExpr.getPosition();
  // llvm::errs() << "Symbol[" << position << "]\n";
  resultAccessPattern.containNeededDim = false;
  resultAccessPattern.containSymbol = true;
  resultAccessPattern.containOtherDim = false;
  resultAccessPattern.a = 0;
  resultAccessPattern.b = 0;
  resultAccessPattern.stepLength = 0;
  resultAccessPattern.stepHigh = 0;
}

static void initConstantPattern(AccessPattern &resultAccessPattern,
                                int64_t value) {
  // llvm::errs() << "Constant(" << value << ")\n";
  resultAccessPattern.containNeededDim = false;
  resultAccessPattern.containSymbol = false;
  resultAccessPattern.containOtherDim = false;
  resultAccessPattern.a = 0;
  resultAccessPattern.b = value;
  resultAccessPattern.stepLength = 0;
  resultAccessPattern.stepHigh = 0;
}

// 合并两个AccessPattern, 结果存放在resultPattern中. the `resultPattern` can also be `pattern1` or `pattern2`.
void mlir::affine::addAccessPatterns(AccessPattern &resultPattern,
                                     const AccessPattern &pattern1,
                                     const AccessPattern &pattern2) {
  // 合并pattern
  resultPattern.containNeededDim = pattern1.containNeededDim || pattern2.containNeededDim;
  resultPattern.containSymbol = pattern1.containSymbol || pattern2.containSymbol;
  resultPattern.containOtherDim = pattern1.containOtherDim || pattern2.containOtherDim;
  
  // a的合并: 直接相加
  resultPattern.a = pattern1.a + pattern2.a;
  // b的合并: 直接相加
  resultPattern.b = pattern1.b + pattern2.b;
  // stepLength的合并: 还没想好, 理论上来讲, 应该是细化了stepLength, 让stepLength划分得更细了
  if(pattern1.stepLength == 0) {
    // stepLength不为0, 就一定有stepHigh就一定不为0
    // left == 0, right != 0 和 left == 0, right == 0 的情况
    resultPattern.stepLength = pattern2.stepLength;
    resultPattern.stepHigh = pattern2.stepHigh;
  } else if(pattern2.stepLength == 0) {
    // left != 0, right == 0 的情况
    resultPattern.stepLength = pattern1.stepLength;
    resultPattern.stepHigh = pattern1.stepHigh;
  } else {
    // left != 0, right != 0 的情况
    if(pattern1.stepLength == pattern2.stepLength) {
      // stepLength相等, stepHigh相加
      resultPattern.stepLength = pattern1.stepLength;
      resultPattern.stepHigh = pattern1.stepHigh + pattern2.stepHigh;
    } else {
      // stepLength不相等, 暂时没想好, 没遇到例子
      llvm::errs()
          << "LoopAnalysis.cpp: addAccessPatterns(): stepLength of pattern1 "
             "and pattern2 are not equal. We can not process it now!\n";
      exit(-1);
    }
  }
  return;
}

static void mulAccessPatterns(AccessPattern &resultPattern,
                              const AccessPattern &pattern1,
                              const AccessPattern &pattern2) {
  resultPattern.containNeededDim = pattern1.containNeededDim || pattern2.containNeededDim;
  resultPattern.containSymbol = pattern1.containSymbol || pattern2.containSymbol;
  resultPattern.containOtherDim = pattern1.containOtherDim || pattern2.containOtherDim;
  // 根据规范, mul的右操作数不可能为dim类, 所以不可能出现两个dim相乘的情况
  if(pattern1.containOtherDim) {
    // left subtree: d1 * or / or mod blabla
    resultPattern.a = 0;
    resultPattern.b = 0;
    resultPattern.stepLength = 0;
    resultPattern.stepHigh = 0;
  } else if(pattern1.containNeededDim) {
    if(pattern1.containSymbol) {
      // left subtree: d0 * s0
      llvm::errs()
          << "LoopAnalysis.cpp: mulAccessPatterns(): Mul: left subtree has "
             "neededDim and symbol. We can not process it now!\n";
      exit(-1);
    } else {
      // left subtree: d0 * or / or mod constant
      if(pattern2.containSymbol) {
        // right subtree: s0
        llvm::errs() << "LoopAnalysis.cpp: mulAccessPatterns(): Mul: right "
                        "subtree is symbol. We can not process it now!\n";
        exit(-1);
      } else {
        // right subtree: constant
        resultPattern.a = pattern1.a * pattern2.b;
        if(pattern1.b != 0) {
          // In our guess, in Mul expr, if left subtree has dim, its `b` should be 0.
          // `b` should only be changed in `Add` process.
          llvm::errs()
              << "LoopAnalysis.cpp: mulAccessPatterns(): Mul: left subtree has "
                 "neededDim, but `b` != 0, do not fit our guess, check it!\n";
          exit(-1);
        }
        resultPattern.b = pattern1.b;  // == 0
        resultPattern.stepLength = pattern1.stepLength;
        resultPattern.stepHigh = pattern1.stepHigh * pattern2.b;
      }
    }
  } else if(pattern1.containSymbol) {
    // left subtree: s0
    resultPattern.a = pattern1.a;  // == 0
    resultPattern.b = pattern1.b;  // == 0
    resultPattern.stepLength = pattern1.stepLength;  // == 0
    resultPattern.stepHigh = pattern1.stepHigh;  // == 0
  } else {
    // left subtree is constant.
    // Now, we guess: left subtree will not be a constant, or constant
    // expr, if an expr has a constant, it will be in the right subtree.
    llvm::errs() << "LoopAnalysis.cpp: mulAccessPatterns(): Mul: left subtree "
                    "is constant. Do not fit our guess, check it!\n";
    exit(-1);
  }
}

static void floorDivAccessPatterns(AccessPattern &resultPattern,
                                   const AccessPattern &pattern1,
                                   const AccessPattern &pattern2) {
  resultPattern.containNeededDim = pattern1.containNeededDim || pattern2.containNeededDim;
  resultPattern.containSymbol = pattern1.containSymbol || pattern2.containSymbol;
  resultPattern.containOtherDim = pattern1.containOtherDim || pattern2.containOtherDim;
  // 根据规范, floorDiv的右操作数不可能为dim类, 所以不可能出现两个dim相除的情况
  if(pattern1.containOtherDim) {
    // left subtree: d1 * or / or mod blabla
    resultPattern.a = 0;
    resultPattern.b = 0;
    resultPattern.stepLength = 0;
    resultPattern.stepHigh = 0;
  } else if(pattern1.containNeededDim) {
    if(pattern1.containSymbol) {
      // left subtree: d0 / s0
      llvm::errs()
          << "LoopAnalysis.cpp: floorDivAccessPatterns(): FloorDiv: left "
             "subtree has neededDim and symbol. We can not process it now!\n";
      exit(-1);
    } else {
      // left subtree: d0 * or / or mod constant
      if(pattern2.containSymbol) {
        // right subtree: s0
        llvm::errs() << "LoopAnalysis.cpp: floorDivAccessPatterns(): FloorDiv: "
                        "right subtree is symbol. We can not process it now!\n";
        exit(-1);
      } else {
        // right subtree: constant
        if(pattern1.a != 1) {
          // For example: left subtree: d0 * 5, right subtree: 32; the
          // whole expr is: d0 * 5 / 32; the `a` how change?
          // `stepLength` how change? Need further analysis.
          // 现在还没遇到例子, 遇到例子再说.
          llvm::errs() << "LoopAnalysis.cpp: floorDivAccessPatterns(): "
                          "FloorDiv: left subtree has neededDim, but `a` != 0, "
                          "we can not process it now!\n";
          exit(-1);
        }
        resultPattern.a = 0;
        if(pattern1.b != 0) {
          // In our guess, in FloorDiv expr, if left subtree has dim, its `b`
          // should be 0
          llvm::errs() << "LoopAnalysis.cpp: floorDivAccessPatterns(): "
                          "FloorDiv: left subtree has neededDim, but `b` != 0, "
                          "do not fit our guess, check it!\n";
          exit(-1);
        }
        resultPattern.b = pattern1.b;  // == 0
        if(pattern1.stepLength == 0) {
          // left subtree: d0; right subtree: constant; 
          // the whole expr is: d0 / constant
          resultPattern.stepLength = pattern2.b;
          resultPattern.stepHigh = 1;
        } else {
          // left subtree: d0 / constant, right subtree: constant1; 
          // the whole expr is: d0 / constant / constant1
          resultPattern.stepLength = pattern1.stepLength * pattern2.b;
          resultPattern.stepHigh = pattern1.stepHigh;
        }
      }
    }
  } else if(pattern1.containSymbol) {
    // left subtree: s0
    resultPattern.a = pattern1.a;  // == 0
    resultPattern.b = pattern1.b;  // == 0
    resultPattern.stepLength = pattern1.stepLength;  // == 0
    resultPattern.stepHigh = pattern1.stepHigh;  // == 0
  } else {
    // left subtree is constant.
    // Now, we guess: left subtree will not be a constant, or constant
    // expr, if an expr has a constant, it will be in the right subtree.
    llvm::errs()
        << "LoopAnalysis.cpp: floorDivAccessPatterns(): FloorDiv: left subtree "
           "is constant. Do not fit our guess, check it!\n";
    exit(-1);
  }
}

// 如果符合预期, accessPattern 为非空, 里面填充了东西, 否则为空
// input args: accessPattern: nullptr, constantValue: nullptr
// output args: accessPattern: non-nullptr, or constantValue: non-nullptr, 
//              or both are nullptr.
static void traverseAffineExpr(AffineExpr expr, unsigned int neededDimPosition,
                               AccessPattern &accessPattern) {
  // *accessPatternAddr = new AccessPattern();
  // AccessPattern *accessPattern = *accessPatternAddr;
  switch (expr.getKind()) {
    // 处理维度标识符
    case AffineExprKind::DimId: {
      auto dimExpr = expr.cast<AffineDimExpr>();
      unsigned position = dimExpr.getPosition();
      // print
      // llvm::errs() << "Dim[" << position << "]\n";
      
      if(position == neededDimPosition) {
        // expr为d0, 对应的pattern为: y = x; 即: [[1, 0], [0, 0]]
        accessPattern.containNeededDim = true;
        accessPattern.containOtherDim = false;
        accessPattern.a = 1;
        
      } else {
        accessPattern.containNeededDim = false;
        accessPattern.containOtherDim = true;
        accessPattern.a = 0;
      }
      accessPattern.containSymbol = false;
      accessPattern.b = 0;
      accessPattern.stepLength = 0;
      accessPattern.stepHigh = 0;
      break;
    }
    // 处理符号标识符
    case AffineExprKind::SymbolId: {
      initSymbolIdPattern(accessPattern);
      break;
    }
    // 处理常量
    case AffineExprKind::Constant: {
      auto constExpr = expr.cast<AffineConstantExpr>();
      int64_t value = constExpr.getValue();
      initConstantPattern(accessPattern, value);
      break;
    }
    // 处理二元操作（Add、Mul、Mod等）
    case AffineExprKind::Add:
    case AffineExprKind::Mul:
    case AffineExprKind::Mod:
    case AffineExprKind::FloorDiv:
    case AffineExprKind::CeilDiv: {
      auto binOpExpr = expr.cast<AffineBinaryOpExpr>();
      // 先递归遍历左子树
      AccessPattern leftAccessPattern, rightAccessPattern;
      traverseAffineExpr(binOpExpr.getLHS(), neededDimPosition, leftAccessPattern);
      // 然后递归遍历右子树
      traverseAffineExpr(binOpExpr.getRHS(), neededDimPosition, rightAccessPattern);
      // 处理当前操作符
      llvm::errs() << "Op: " << (int)binOpExpr.getKind() << "\n";

      switch (binOpExpr.getKind()) {
        case AffineExprKind::Add: {
          addAccessPatterns(accessPattern, leftAccessPattern, rightAccessPattern);
          break;
        }
        case AffineExprKind::Mul: {
          mulAccessPatterns(accessPattern, leftAccessPattern, rightAccessPattern);
          break;
        }
        case AffineExprKind::FloorDiv: {
          floorDivAccessPatterns(accessPattern, leftAccessPattern, rightAccessPattern);
          break;
        }
        default: {
          llvm::errs()
              << "LoopAnalysis.cpp: traverseAffineExpr(): kind is not Add, Mul "
                 "or FloorDiv: We can not process this kind of expr now!\n";
          exit(-1);
        }
      }
      break;
    }
    default:
      llvm_unreachable("LoopAnalysis.cpp: traverseAffineExpr(): 未知的AffineExpr类型");
  }
  return;
}




// 原来的isAccessIndexInvariant()的问题: 只能检测出iv 和 index
// 是否有关, 但是不能检测出iv 和 index
// 的具体关系, 如是否是线性关系, 或者阶梯突变关系等.  线性关系示意图: 
///      index
///      ^
///      |
///   63 |                             *
///      |                         *
///      |                      *
///      |                   *
///      |                *
///   31 |             *
///      |          *
///      |       *
///      |    *
///      | *
///   0  *--------------------------------> iv
///     0  1  2  ...  31  32 33  ...  63
///
// 阶梯突变关系示意图: 
///      index
///      ^
///      |
///   63 |
///      |
///      |
///      |
///   31 |                *  *  *  *  *
///      |
///      |
///      |
///      | *  *  *  *  *
///   0  *--------------------------------> iv
///     0  1  2  ...  31  32 33  ...  63
// 因为线性关系和阶梯突变关系, 在向量化时, 处理方式是不同的: 
// %4 = affine.load %arg0[%arg4]; 如果arg4 和
// 我们要向量化的iv是线性关系, 那就可以变为: 
// ->
// %4_vec = vector.transfer_read %arg0[%arg4];
// 如果arg4 和 我们要向量化的iv是阶梯突变关系, 那对它的向量化处理应该为: 
// ->
// %4 = affine.load %arg0[%arg4];
// %4_vec = vector.broadcast %4;

// Returns true if `iv` is linear with `index`, false otherwise. Here `linear`
// is defined as: `iv` + 1, `index` + 1, `iv` - 1, `index` - 1.
// If false, the relation may be more complex, e.g., `iv` + 1 -> `index` + 0,
// `iv` + 2 -> `index` + 0, ..., `iv` + 31 -> `index` + 0, `iv` + 32 -> `index`
// + 32.
void mlir::affine::isLinearWithIndex(Value iv, Value index,
                                     AccessPattern &accessPattern) {
  assert(isAffineForInductionVar(iv) && "iv must be a AffineForOp");
  // assert(isa<IndexType>(index.getType()) && "index must be of IndexType");
  // SmallVector<Operation *, 4> affineApplyOps;
  // getReachableAffineApplyOps({index}, affineApplyOps);

  // `index` is not result of an AffineApplyOp, it may be an iv.
  // Pointer equality test because of Value pointer semantics.
  if (iv == index) {
    // index is exactly the `iv`, they are surely linear.
    // 这里似乎不太对, 并不代表就是线性的了；
    accessPattern.containNeededDim = true;
    accessPattern.containSymbol = false;
    accessPattern.containOtherDim = false;
    accessPattern.a = 1;
    accessPattern.b = 0;
    accessPattern.stepLength = 0;
    accessPattern.stepHigh = 0;
    return;
  } else {
    // `index` is not the same as `iv`, need further analysis.
    // In the current `gemv` case, `index` is `arg4`, `iv` is `arg3`, they are
    // both iv, but not the same: arg4 is applied by an affine.apply(arg3).
    // is `index` is a iv of an AffineForOp?
    if (isAffineForInductionVar(index)) {
      AffineForOp affineForOp = getForInductionVarOwner(index);

      // The affine.load's index is not the vectorized iv (of forA), but it is
      // an iv of an AffineForOp (forB). So, we need to check the relation
      // between the iv of forA and forB.
      auto lbMapOperands = affineForOp.getLowerBoundOperands();
      auto lbMap = affineForOp.getLowerBoundMap();
      // check if lbMapOperands contains `iv`
      if (std::find(lbMapOperands.begin(), lbMapOperands.end(), iv) != lbMapOperands.end()) {
        // iv is in lbMapOperands
        llvm::errs() << "LoopAnalysis.cpp: isLinearWithIndex(): iv is in lbMapOperands\n";
        if(lbMapOperands.size() == 1) {
          // Here we assume that the lbMapOperands has only 1 operand. 
          // Check lbMap: 
          if(lbMap.getNumResults() == 1) {
            auto resultExpr = lbMap.getResult(0);
            // Process the resultExpr
            traverseAffineExpr(resultExpr, 0, accessPattern);
          } else {
            llvm::errs() << "LoopAnalysis.cpp: isLinearWithIndex(): lbMap's "
                            "resultExpr's size != 1\n";
            exit(-1);
          }
          // auto resultExpr = accessMap.getResult(i);
          // resultExpr.walk([&](AffineExpr expr) {
          //   if (auto dimExpr = expr.dyn_cast<AffineDimExpr>())
          //     exprOperands.push_back(mapOperands[dimExpr.getPosition()]);
          //   else if (auto symExpr = expr.dyn_cast<AffineSymbolExpr>())
          //     exprOperands.push_back(mapOperands[numDims + symExpr.getPosition()]);
          // });
        } else {
          llvm::errs() << "LoopAnalysis.cpp: isLinearWithIndex(): "
                          "lbMapOperands.size() != 1. We can not process "
                          "this situation.\n";
          llvm::errs() << "LoopAnalysis.cpp: isLinearWithIndex(): lbMapOperands: \n";
          for (auto operand : lbMapOperands) {
            operand.dump();
            llvm::errs() << "\n";
          }
          llvm::errs() << "\n\n";
          exit(-1);
        }
      }
      else {
        // iv is not in lbMapOperands
        llvm::errs() << "LoopAnalysis.cpp: isLinearWithIndex(): iv is not in "
                        "lbMapOperands, check it!\n";
        exit(-1);
      }
    }
  }
  // if (auto affineApplyOp = index.getDefiningOp<AffineApplyOp>()) {
  //   if (affineApplyOp.getNumOperands() == 1 && affineApplyOp.getOperand(0) == iv)
  //     return true;
  // }
  return;
}

// TODO: args中的mapOperand似乎没用, 通过mapOperandPosition来确定顺序了
void mlir::affine::relationOfMapOperandWithMemoryOp(
    const AffineExpr &expr, unsigned mapOperandPosition,
    const AccessPattern &dimIdInitAccessPattern,
    AccessPattern &resultAccessPattern) {
  switch (expr.getKind()) {
    case AffineExprKind::DimId: {
      auto dimExpr = expr.cast<AffineDimExpr>();
      unsigned position = dimExpr.getPosition();
      if(position == mapOperandPosition) {
        // expr为d0, 对应的pattern为: dimIdInitAccessPattern
        resultAccessPattern = dimIdInitAccessPattern;
      } else {
        resultAccessPattern.containNeededDim = false;
        resultAccessPattern.containSymbol = false;
        resultAccessPattern.containOtherDim = true;
        resultAccessPattern.a = 0;
        resultAccessPattern.b = 0;
        resultAccessPattern.stepLength = 0;
        resultAccessPattern.stepHigh = 0;
      }
      break;
    }
    case AffineExprKind::SymbolId: {
      initSymbolIdPattern(resultAccessPattern);
      break;
    }
    case AffineExprKind::Constant: {
      auto constExpr = expr.cast<AffineConstantExpr>();
      int64_t value = constExpr.getValue();
      initConstantPattern(resultAccessPattern, value);
      break;
    }
    // 处理二元操作（Add、Mul、Mod等）
    case AffineExprKind::Add:
    case AffineExprKind::Mul:
    case AffineExprKind::Mod:
    case AffineExprKind::FloorDiv:
    case AffineExprKind::CeilDiv: {
      auto binOpExpr = expr.cast<AffineBinaryOpExpr>();
      // 先递归遍历左子树
      AccessPattern leftAccessPattern, rightAccessPattern;
      relationOfMapOperandWithMemoryOp(binOpExpr.getLHS(), mapOperandPosition,
                                       dimIdInitAccessPattern,
                                       leftAccessPattern);
      // 然后递归遍历右子树
      relationOfMapOperandWithMemoryOp(binOpExpr.getRHS(), mapOperandPosition,
                                       dimIdInitAccessPattern,
                                       rightAccessPattern);
      // 处理当前操作符
      llvm::errs() << "Op: " << (int)binOpExpr.getKind() << "\n";

      switch (binOpExpr.getKind()) {
        case AffineExprKind::Add: {
          addAccessPatterns(resultAccessPattern, leftAccessPattern, rightAccessPattern);
          break;
        }
        case AffineExprKind::Mul: {
          mulAccessPatterns(resultAccessPattern, leftAccessPattern, rightAccessPattern);
          break;
        }
        case AffineExprKind::FloorDiv: {
          floorDivAccessPatterns(resultAccessPattern, leftAccessPattern, rightAccessPattern);
          break;
        }
        default: {
          llvm::errs()
              << "LoopAnalysis.cpp: relationOfMapOperandWithMemoryOp(): kind "
                 "is not Add, Mul or FloorDiv: We can not process this kind of "
                 "expr now!\n";
          exit(-1);
        }
      }
      break;
    }
    default:
      llvm_unreachable("LoopAnalysis.cpp: relationOfMapOperandWithMemoryOp(): "
                       "未知的AffineExpr类型");
  }
  return;
}

DenseSet<Value> mlir::affine::getInvariantAccesses(Value iv,
                                                   ArrayRef<Value> indices) {
  DenseSet<Value> res;
  for (auto val : indices) {
    if (isAccessIndexInvariant(iv, val)) {
      res.insert(val);
    }
  }
  return res;
}

/// Given:
///   1. an induction variable `iv` of type AffineForOp;
///   2. a `memoryOp` of type const LoadOp& or const StoreOp&;
/// determines whether `memoryOp` has a contiguous access along `iv`. Contiguous
/// is defined as either invariant or varying only along a unique MemRef dim.
/// Upon success, the unique MemRef dim is written in `memRefDim` (or -1 to
/// convey the memRef access is invariant along `iv`).
///
/// Prerequisites:
///   1. `memRefDim` ~= nullptr;
///   2. `iv` of the proper type;
///   3. the MemRef accessed by `memoryOp` has no layout map or at most an
///      identity layout map.
///
/// Currently only supports no layoutMap or identity layoutMap in the MemRef.
/// Returns false if the MemRef has a non-identity layoutMap or more than 1
/// layoutMap. This is conservative.
///
// TODO: check strides.
template <typename LoadOrStoreOp>
static bool isContiguousAccess(Value iv, LoadOrStoreOp memoryOp,
                               int *memRefDim) {
  static_assert(
      llvm::is_one_of<LoadOrStoreOp, AffineLoadOp, AffineStoreOp>::value,
      "Must be called on either LoadOp or StoreOp");
  assert(memRefDim && "memRefDim == nullptr");
  auto memRefType = memoryOp.getMemRefType();

  if (!memRefType.getLayout().isIdentity())
    return memoryOp.emitError("NYI: non-trivial layoutMap"), false;

  int uniqueVaryingIndexAlongIv = -1;
  auto accessMap = memoryOp.getAffineMap();
  SmallVector<Value, 4> mapOperands(memoryOp.getMapOperands());
  unsigned numDims = accessMap.getNumDims();
  for (unsigned i = 0, e = memRefType.getRank(); i < e; ++i) {
    // Gather map operands used result expr 'i' in 'exprOperands'.
    SmallVector<Value, 4> exprOperands;
    auto resultExpr = accessMap.getResult(i);
    resultExpr.walk([&](AffineExpr expr) {
      if (auto dimExpr = expr.dyn_cast<AffineDimExpr>())
        exprOperands.push_back(mapOperands[dimExpr.getPosition()]);
      else if (auto symExpr = expr.dyn_cast<AffineSymbolExpr>())
        exprOperands.push_back(mapOperands[numDims + symExpr.getPosition()]);
    });
    // exprOperands 的大小: map 表达式中, 一共有几个子表达式; 
    //              其中存放的是: 每个子表达式所使用的dim或symbol
    // Check access invariance of each operand in 'exprOperands'.
    for (auto exprOperand : exprOperands) {
      if (!isAccessIndexInvariant(iv, exprOperand)) {
        llvm::errs() << "LoopAnalysis.cpp: isContiguousAccess(): "
                        "isAccessIndexInvariant() false\n";
        if (uniqueVaryingIndexAlongIv != -1) {
          // 2+ varying indices -> do not vectorize along iv.
          // 第3个loop, 因为第2个affine.load里面, 在这里的判断, 而false
          // 因为一个affine map中, 有两个和iv相关的index, 所以返回false.
          // 应该是因为它对访存pattern分析得不够导致只能采取比较保守的办法,
          // 即直接说无法向量化, 但我引入AccessPattern之后,
          // 分析能力是更精细了的, 所以可以进行一些处理了.
          // Note: I commented out here, for the case of 2+ varying indices, in
          // gemv case. return false;
          llvm::errs()
              << "mlir::affine::isContiguousAccess(): 2+ varying indices -> "
                 "original do not vectorize along iv, but I allow this case\n";
        }
        uniqueVaryingIndexAlongIv = i;
      }
      else {
        llvm::errs() << "LoopAnalysis.cpp: isContiguousAccess(): "
                        "isAccessIndexInvariant() true\n";
        AccessPattern accessPattern;
        isLinearWithIndex(iv, exprOperand, accessPattern);
      }
    }
  }

  if (uniqueVaryingIndexAlongIv == -1)
    *memRefDim = -1;
  else
    *memRefDim = memRefType.getRank() - (uniqueVaryingIndexAlongIv + 1);
  return true;
}

template <typename LoadOrStoreOp>
static bool isVectorElement(LoadOrStoreOp memoryOp) {
  auto memRefType = memoryOp.getMemRefType();
  return isa<VectorType>(memRefType.getElementType());
}

using VectorizableOpFun = std::function<bool(AffineForOp, Operation &)>;

static bool
isVectorizableLoopBodyWithOpCond(AffineForOp loop,
                                 const VectorizableOpFun &isVectorizableOp,
                                 NestedPattern &vectorTransferMatcher) {
  auto *forOp = loop.getOperation();

  // No vectorization across conditionals for now.
  // 他们当前不支持对if的向量化, 在这里通过match匹配是否有if, 如果有if, 就判断不能向量化, 返回false
  auto conditionals = matcher::If();
  SmallVector<NestedMatch, 8> conditionalsMatched;
  conditionals.match(forOp, &conditionalsMatched);
  if (!conditionalsMatched.empty()) {
    // Note: Here I allow the case of if, because I want to vectorize the gemv case, like this:
    //   for (i = 0; i < N; i++) {
    //     if(xx == 0) {
    //       ...
    //     } 
    //   }
    // return false;
    llvm::errs() << "\nisVectorizableLoopBodyWithOpCond(): if "
                  "case can be vectorized.\n";
  }

  // No vectorization for ops with operand or result types that are not
  // vectorizable.
  auto types = matcher::Op([](Operation &op) -> bool {
    if (llvm::any_of(op.getOperandTypes(), [](Type type) {
          if (MemRefType t = dyn_cast<MemRefType>(type))
            return !VectorType::isValidElementType(t.getElementType());
          return !VectorType::isValidElementType(type);
        }))
      return true;
    return llvm::any_of(op.getResultTypes(), [](Type type) {
      return !VectorType::isValidElementType(type);
    });
  });
  SmallVector<NestedMatch, 8> opsMatched;
  types.match(forOp, &opsMatched);
  if (!opsMatched.empty()) {
    return false;
  }

  // No vectorization across unknown regions.
  auto regions = matcher::Op([](Operation &op) -> bool {
    return op.getNumRegions() != 0 && !isa<AffineIfOp, AffineForOp>(op);
  });
  SmallVector<NestedMatch, 8> regionsMatched;
  regions.match(forOp, &regionsMatched);
  if (!regionsMatched.empty()) {
    return false;
  }

  SmallVector<NestedMatch, 8> vectorTransfersMatched;
  vectorTransferMatcher.match(forOp, &vectorTransfersMatched);
  if (!vectorTransfersMatched.empty()) {
    return false;
  }

  auto loadAndStores = matcher::Op(matcher::isLoadOrStore);
  SmallVector<NestedMatch, 8> loadAndStoresMatched;
  loadAndStores.match(forOp, &loadAndStoresMatched);
  for (auto ls : loadAndStoresMatched) {
    auto *op = ls.getMatchedOperation();
    auto load = dyn_cast<AffineLoadOp>(op);
    auto store = dyn_cast<AffineStoreOp>(op);
    // Only scalar types are considered vectorizable, all load/store must be
    // vectorizable for a loop to qualify as vectorizable.
    // TODO: ponder whether we want to be more general here.
    bool vector = load ? isVectorElement(load) : isVectorElement(store);
    if (vector) {
      return false;
    }
    // 第3个loop, 是在这里这个判断出问题的；
    if (isVectorizableOp && !isVectorizableOp(loop, *op)) {
      return false;
    }
  }
  return true;
}

bool mlir::affine::isVectorizableLoopBody(
    AffineForOp loop, int *memRefDim, NestedPattern &vectorTransferMatcher) {
  // 这里要看看, 是不是所谓的match, 其实就是这个function的判断？
  // 我估摸着, Pattern, 其实就是这个filter函数, 离谱
  *memRefDim = -1;
  VectorizableOpFun fun([memRefDim](AffineForOp loop, Operation &op) {
    auto load = dyn_cast<AffineLoadOp>(op);
    auto store = dyn_cast<AffineStoreOp>(op);
    int thisOpMemRefDim = -1;
    bool isContiguous = load ? isContiguousAccess(loop.getInductionVar(), load,
                                                  &thisOpMemRefDim)
                             : isContiguousAccess(loop.getInductionVar(), store,
                                                  &thisOpMemRefDim);
    if (thisOpMemRefDim != -1) {
      // If memory accesses vary across different dimensions then the loop is
      // not vectorizable.
      if (*memRefDim != -1 && *memRefDim != thisOpMemRefDim)
        return false;
      *memRefDim = thisOpMemRefDim;
    }
    return isContiguous;
  });
  return isVectorizableLoopBodyWithOpCond(loop, fun, vectorTransferMatcher);
}

bool mlir::affine::isVectorizableLoopBody(
    AffineForOp loop, NestedPattern &vectorTransferMatcher) {
  return isVectorizableLoopBodyWithOpCond(loop, nullptr, vectorTransferMatcher);
}

/// Checks whether SSA dominance would be violated if a for op's body
/// operations are shifted by the specified shifts. This method checks if a
/// 'def' and all its uses have the same shift factor.
// TODO: extend this to check for memory-based dependence violation when we have
// the support.
bool mlir::affine::isOpwiseShiftValid(AffineForOp forOp,
                                      ArrayRef<uint64_t> shifts) {
  auto *forBody = forOp.getBody();
  assert(shifts.size() == forBody->getOperations().size());

  // Work backwards over the body of the block so that the shift of a use's
  // ancestor operation in the block gets recorded before it's looked up.
  DenseMap<Operation *, uint64_t> forBodyShift;
  for (const auto &it :
       llvm::enumerate(llvm::reverse(forBody->getOperations()))) {
    auto &op = it.value();

    // Get the index of the current operation, note that we are iterating in
    // reverse so we need to fix it up.
    size_t index = shifts.size() - it.index() - 1;

    // Remember the shift of this operation.
    uint64_t shift = shifts[index];
    forBodyShift.try_emplace(&op, shift);

    // Validate the results of this operation if it were to be shifted.
    for (unsigned i = 0, e = op.getNumResults(); i < e; ++i) {
      Value result = op.getResult(i);
      for (auto *user : result.getUsers()) {
        // If an ancestor operation doesn't lie in the block of forOp,
        // there is no shift to check.
        if (auto *ancOp = forBody->findAncestorOpInBlock(*user)) {
          assert(forBodyShift.count(ancOp) > 0 && "ancestor expected in map");
          if (shift != forBodyShift[ancOp])
            return false;
        }
      }
    }
  }
  return true;
}
