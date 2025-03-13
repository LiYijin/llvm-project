//===- LoopAnalysis.h - loop analysis methods -------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This header file defines prototypes for methods to analyze loops.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_AFFINE_ANALYSIS_LOOPANALYSIS_H
#define MLIR_DIALECT_AFFINE_ANALYSIS_LOOPANALYSIS_H

#include "mlir/Support/LLVM.h"
#include "llvm/ADT/ArrayRef.h"
#include <optional>

namespace mlir {
class AffineExpr;
class AffineMap;
class BlockArgument;
class MemRefType;
class Operation;
class Value;

namespace affine {
class AffineForOp;
class NestedPattern;

/// Returns the trip count of the loop as an affine map with its corresponding
/// operands if the latter is expressible as an affine expression, and nullptr
/// otherwise. This method always succeeds as long as the lower bound is not a
/// multi-result map. The trip count expression is simplified before returning.
/// This method only utilizes map composition to construct lower and upper
/// bounds before computing the trip count expressions
void getTripCountMapAndOperands(AffineForOp forOp, AffineMap *map,
                                SmallVectorImpl<Value> *operands);

/// Returns the trip count of the loop if it's a constant, std::nullopt
/// otherwise. This uses affine expression analysis and is able to determine
/// constant trip count in non-trivial cases.
std::optional<uint64_t> getConstantTripCount(AffineForOp forOp);

/// Returns the greatest known integral divisor of the trip count. Affine
/// expression analysis is used (indirectly through getTripCount), and
/// this method is thus able to determine non-trivial divisors.
uint64_t getLargestDivisorOfTripCount(AffineForOp forOp);

/// Given an induction variable `iv` of type AffineForOp and `indices` of type
/// IndexType, returns the set of `indices` that are independent of `iv`.
///
/// Prerequisites (inherited from `isAccessInvariant` above):
///   1. `iv` and `indices` of the proper type;
///   2. at most one affine.apply is reachable from each index in `indices`;
///
/// Emits a note if it encounters a chain of affine.apply and conservatively
///  those cases.
DenseSet<Value, DenseMapInfo<Value>>
getInvariantAccesses(Value iv, ArrayRef<Value> indices);

using VectorizableLoopFun = std::function<bool(AffineForOp)>;

/// Checks whether the loop is structurally vectorizable; i.e.:
///   1. no conditionals are nested under the loop;
///   2. all nested load/stores are to scalar MemRefs.
/// TODO: relax the no-conditionals restriction
bool isVectorizableLoopBody(AffineForOp loop,
                            NestedPattern &vectorTransferMatcher);

/// Checks whether the loop is structurally vectorizable and that all the LoadOp
/// and StoreOp matched have access indexing functions that are either:
///   1. invariant along the loop induction variable created by 'loop';
///   2. varying along at most one memory dimension. If such a unique dimension
///      is found, it is written into `memRefDim`.
bool isVectorizableLoopBody(AffineForOp loop, int *memRefDim,
                            NestedPattern &vectorTransferMatcher);

// 相邻cuda线程间, 内存访问的pattern, 用于check能否沿CUDA 线程向量化, 以及如何向量化, 以及向量化因子的选择。现在的struct还比较初步, 后期根据遇到的用例, 可能还会修改AccessPattern这个struct
struct AccessPattern
{
  int a, b;  // y = a * x + b;    默认应该为0
  // 有的访问模式会有`台阶`出现, 比如d0 / 32, 这种情况: stepLength = 32, stepHigh = 1
  // (d0 / 32) * 32: stepLength = 32, stepHigh = 1
  int stepLength, stepHigh;   // step's length and high;  默认应该为0
  bool containNeededDim;    // 当前expr是否包含我们care的dimId, 默认为flase
  bool containSymbol;  // 是否是symbol, 或者和symbol有关, 默认应该为false
  bool containOtherDim;     // 当前expr是否包含我们不care的其他dimId, 默认为false
};

// the `iv` is the vectorized dim block argument of loop, the index is loadOp's mapOperand.
void isLinearWithIndex(Value iv, Value index, AccessPattern &pattern);

void addAccessPatterns(AccessPattern &pattern1, const AccessPattern &pattern2,
                       const AccessPattern &resultPattern);

// Compute the influence of `mapOperand` to the whole map.
// `mapOperand` is an operand of a loadOp's Map, should be a dim. 
// `mapOperandPosition` is the position of this dim. 
// `accessPattern` is the AccessPattern of this dim, which got from isLinearWithIndex() API. Compute should start from the `accessPattern`.
void relationOfMapOperandWithMemoryOp(
    const AffineExpr &expr, unsigned mapOperandPosition,
    const AccessPattern &dimIdInitAccessPattern,
    AccessPattern &resultAccessPattern);

/// Checks where SSA dominance would be violated if a for op's body
/// operations are shifted by the specified shifts. This method checks if a
/// 'def' and all its uses have the same shift factor.
// TODO: extend this to check for memory-based dependence violation when we have
// the support.
bool isOpwiseShiftValid(AffineForOp forOp, ArrayRef<uint64_t> shifts);

} // namespace affine
} // namespace mlir

#endif // MLIR_DIALECT_AFFINE_ANALYSIS_LOOPANALYSIS_H
