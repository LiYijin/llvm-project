//===- TranslateToCpp.cpp - Translating to C++ calls ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Dialect/EmitC/IR/EmitC.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/NPU/IR/NPUDialect.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Support/IndentedOstream.h"
#include "mlir/Support/LLVM.h"
#include "mlir/Target/Cpp/CppEmitter.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/ScopedHashTable.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FormatVariadic.h"
#include <stack>
#include <utility>

#define DEBUG_TYPE "translate-to-cpp"

using namespace mlir;
using namespace mlir::emitc;
using llvm::formatv;

#define GEN_CCE_CODE
// #define GEN_BISHENGCPP_CODE

/// Convenience functions to produce interleaved output with functions returning
/// a LogicalResult. This is different than those in STLExtras as functions used
/// on each element doesn't return a string.
template <typename ForwardIterator, typename UnaryFunctor,
          typename NullaryFunctor>
inline LogicalResult
interleaveWithError(ForwardIterator begin, ForwardIterator end,
                    UnaryFunctor eachFn, NullaryFunctor betweenFn) {
  if (begin == end)
    return success();
  if (failed(eachFn(*begin)))
    return failure();
  ++begin;
  for (; begin != end; ++begin) {
    betweenFn();
    if (failed(eachFn(*begin)))
      return failure();
  }
  return success();
}

template <typename Container, typename UnaryFunctor, typename NullaryFunctor>
inline LogicalResult interleaveWithError(const Container &c,
                                         UnaryFunctor eachFn,
                                         NullaryFunctor betweenFn) {
  return interleaveWithError(c.begin(), c.end(), eachFn, betweenFn);
}

template <typename Container, typename UnaryFunctor>
inline LogicalResult interleaveCommaWithError(const Container &c,
                                              raw_ostream &os,
                                              UnaryFunctor eachFn) {
  return interleaveWithError(c.begin(), c.end(), eachFn, [&]() { os << ", "; });
}

// For llvm GEPOp, such as:
//   %4 = llvm.getelementptr %0[%3] : (!llvm.ptr<1>, i64) -> !llvm.ptr<1>, f32
// We need print '+' between its operands.
template <typename Container, typename UnaryFunctor>
inline LogicalResult interleaveAddWithError(const Container &c, raw_ostream &os,
                                            UnaryFunctor eachFn) {
  return interleaveWithError(c.begin(), c.end(), eachFn,
                             [&]() { os << " + "; });
}

/// Return the precedence of a operator as an integer, higher values
/// imply higher precedence.
static FailureOr<int> getOperatorPrecedence(Operation *operation) {
  return llvm::TypeSwitch<Operation *, FailureOr<int>>(operation)
      .Case<emitc::AddOp>([&](auto op) { return 12; })
      .Case<emitc::ApplyOp>([&](auto op) { return 15; })
      .Case<emitc::BitwiseAndOp>([&](auto op) { return 7; })
      .Case<emitc::BitwiseLeftShiftOp>([&](auto op) { return 11; })
      .Case<emitc::BitwiseNotOp>([&](auto op) { return 15; })
      .Case<emitc::BitwiseOrOp>([&](auto op) { return 5; })
      .Case<emitc::BitwiseRightShiftOp>([&](auto op) { return 11; })
      .Case<emitc::BitwiseXorOp>([&](auto op) { return 6; })
      // .Case<emitc::CallOp>([&](auto op) { return 16; })
      .Case<emitc::CallOpaqueOp>([&](auto op) { return 16; })
      .Case<emitc::CastOp>([&](auto op) { return 15; })
      .Case<emitc::CmpOp>([&](auto op) -> FailureOr<int> {
        switch (op.getPredicate()) {
        case emitc::CmpPredicate::eq:
        case emitc::CmpPredicate::ne:
          return 8;
        case emitc::CmpPredicate::lt:
        case emitc::CmpPredicate::le:
        case emitc::CmpPredicate::gt:
        case emitc::CmpPredicate::ge:
          return 9;
        case emitc::CmpPredicate::three_way:
          return 10;
        }
        return op->emitError("unsupported cmp predicate");
      })
      .Case<emitc::ConditionalOp>([&](auto op) { return 2; })
      .Case<emitc::DivOp>([&](auto op) { return 13; })
      .Case<emitc::LogicalAndOp>([&](auto op) { return 4; })
      .Case<emitc::LogicalNotOp>([&](auto op) { return 15; })
      .Case<emitc::LogicalOrOp>([&](auto op) { return 3; })
      .Case<emitc::MulOp>([&](auto op) { return 13; })
      .Case<emitc::RemOp>([&](auto op) { return 13; })
      .Case<emitc::SubOp>([&](auto op) { return 12; })
      .Case<emitc::UnaryMinusOp>([&](auto op) { return 15; })
      .Case<emitc::UnaryPlusOp>([&](auto op) { return 15; })
      .Default([](auto op) { return op->emitError("unsupported operation"); });
}

namespace {
/// Emitter that uses dialect specific emitters to emit C++ code.
struct CppEmitter {
  explicit CppEmitter(raw_ostream &os, bool declareVariablesAtTop/*,
                      StringRef fileId*/);
  std::unordered_map<int, Value> AllocationMap;

  /// Emits attribute or returns failure.
  LogicalResult emitAttribute(Location loc, Attribute attr);

  /// Emits operation 'op' with/without training semicolon or returns failure.
  ///
  /// For operations that should never be followed by a semicolon, like ForOp,
  /// the `trailingSemicolon` argument is ignored and a semicolon is not
  /// emitted.
  LogicalResult emitOperation(Operation &op, bool trailingSemicolon);

  /// Emits type 'type' or returns failure.
  LogicalResult emitType(Location loc, Type type);

  /// Emits array of types as a std::tuple of the emitted types.
  /// - emits void for an empty array;
  /// - emits the type of the only element for arrays of size one;
  /// - emits a std::tuple otherwise;
  LogicalResult emitTypes(Location loc, ArrayRef<Type> types);

  /// Emits array of types as a std::tuple of the emitted types independently of
  /// the array size.
  LogicalResult emitTupleType(Location loc, ArrayRef<Type> types);

  /// Emits an assignment for a variable which has been declared previously.
  LogicalResult emitVariableAssignment(OpResult result);

  /// Emits a variable declaration for a result of an operation.
  LogicalResult emitVariableDeclaration(OpResult result,
                                        bool trailingSemicolon);

  /// Emits a declaration of a variable with the given type and name.
  LogicalResult emitVariableDeclaration(Location loc, Type type,
                                        StringRef name);

  /// Emits the variable declaration and assignment prefix for 'op'.
  /// - emits separate variable followed by std::tie for multi-valued operation;
  /// - emits single type followed by variable for single result;
  /// - emits nothing if no value produced by op;
  /// Emits final '=' operator where a type is produced. Returns failure if
  /// any result type could not be converted.
  LogicalResult emitAssignPrefix(Operation &op);

  /// Emits a global variable declaration or definition.
  LogicalResult emitGlobalVariable(GlobalOp op);

  /// Emits a label for the block.
  LogicalResult emitLabel(Block &block);

  /// Emits the operands and atttributes of the operation. All operands are
  /// emitted first and then all attributes in alphabetical order.
  LogicalResult emitOperandsAndAttributes(Operation &op,
                                          ArrayRef<StringRef> exclude = {});

  /// Emits the operands of the operation. All operands are emitted in order.
  LogicalResult emitOperands(Operation &op);

  /// Emits the operands of the operation. All operands should be added together.
  LogicalResult emitAddLikeOperands(Operation &op);

  /// Emits value as an operands of an operation
  LogicalResult emitOperand(Value value);

  /// Emit an expression as a C expression.
  LogicalResult emitExpression(ExpressionOp expressionOp);

  /// Insert the expression representing the operation into the value cache.
  void cacheDeferredOpResult(Value value, StringRef str);

  /// Return the existing or a new name for a Value.
  StringRef getOrCreateName(Value val);

  // Returns the textual representation of a subscript operation.
  std::string getSubscriptName(emitc::SubscriptOp op);

  // Returns the textual representation of a member (of object) operation.
  std::string createMemberAccess(emitc::MemberOp op);

  // Returns the textual representation of a member of pointer operation.
  std::string createMemberAccess(emitc::MemberOfPtrOp op);

  /// Return the existing or a new label of a Block.
  StringRef getOrCreateName(Block &block);

  // Return the allocated buffer name
  StringRef getOrCreateNameAlias(Value val);

  /// Whether to map an mlir integer to a unsigned integer in C++.
  bool shouldMapToUnsigned(IntegerType::SignednessSemantics val);

  /// RAII helper function to manage entering/exiting C++ scopes.
  struct Scope {
    Scope(CppEmitter &emitter)
        : valueMapperScope(emitter.valueMapper),
          blockMapperScope(emitter.blockMapper), emitter(emitter) {
      emitter.valueInScopeCount.push(emitter.valueInScopeCount.top());
      emitter.labelInScopeCount.push(emitter.labelInScopeCount.top());
    }
    ~Scope() {
      emitter.valueInScopeCount.pop();
      emitter.labelInScopeCount.pop();
    }

  private:
    llvm::ScopedHashTableScope<Value, std::string> valueMapperScope;
    llvm::ScopedHashTableScope<Block *, std::string> blockMapperScope;
    CppEmitter &emitter;
  };

  /// Returns wether the Value is assigned to a C++ variable in the scope.
  bool hasValueInScope(Value val);

  // Returns whether a label is assigned to the block.
  bool hasBlockLabel(Block &block);

  /// Returns the output stream.
  raw_indented_ostream &ostream() { return os; };

  /// Returns if all variables for op results and basic block arguments need to
  /// be declared at the beginning of a function.
  bool shouldDeclareVariablesAtTop() { return declareVariablesAtTop; };

  // /// Returns whether this file op should be emitted
  // bool shouldEmitFile(FileOp file) {
  //   return !fileId.empty() && file.getId() == fileId;
  // }

  /// Get expression currently being emitted.
  ExpressionOp getEmittedExpression() { return emittedExpression; }

  /// Determine whether given value is part of the expression potentially being
  /// emitted.
  bool isPartOfCurrentExpression(Value value) {
    if (!emittedExpression)
      return false;
    Operation *def = value.getDefiningOp();
    if (!def)
      return false;
    auto operandExpression = dyn_cast<ExpressionOp>(def->getParentOp());
    return operandExpression == emittedExpression;
  };

private:
  using ValueMapper = llvm::ScopedHashTable<Value, std::string>;
  using BlockMapper = llvm::ScopedHashTable<Block *, std::string>;

  /// Output stream to emit to.
  raw_indented_ostream os;

  /// Boolean to enforce that all variables for op results and block
  /// arguments are declared at the beginning of the function. This also
  /// includes results from ops located in nested regions.
  bool declareVariablesAtTop;

  // /// Only emit file ops whos id matches this value.
  // std::string fileId;

  /// Map from value to name of C++ variable that contain the name.
  ValueMapper valueMapper;

  /// Map from block to name of C++ label.
  BlockMapper blockMapper;

  /// The number of values in the current scope. This is used to declare the
  /// names of values in a scope.
  std::stack<int64_t> valueInScopeCount;
  std::stack<int64_t> labelInScopeCount;

  /// State of the current expression being emitted.
  ExpressionOp emittedExpression;
  SmallVector<int> emittedExpressionPrecedence;

  void pushExpressionPrecedence(int precedence) {
    emittedExpressionPrecedence.push_back(precedence);
  }
  void popExpressionPrecedence() { emittedExpressionPrecedence.pop_back(); }
  static int lowestPrecedence() { return 0; }
  int getExpressionPrecedence() {
    if (emittedExpressionPrecedence.empty())
      return lowestPrecedence();
    return emittedExpressionPrecedence.back();
  }
};
} // namespace

/// Determine whether expression \p op should be emitted in a deferred way.
static bool hasDeferredEmission(Operation *op) {
  return isa_and_nonnull<emitc::GetGlobalOp, emitc::LiteralOp, emitc::MemberOp,
                         emitc::MemberOfPtrOp, emitc::SubscriptOp>(op);
}

/// Determine whether expression \p expressionOp should be emitted inline, i.e.
/// as part of its user. This function recommends inlining of any expressions
/// that can be inlined unless it is used by another expression, under the
/// assumption that  any expression fusion/re-materialization was taken care of
/// by transformations run by the backend.
static bool shouldBeInlined(ExpressionOp expressionOp) {
  // Do not inline if expression is marked as such.
  if (expressionOp.getDoNotInline())
    return false;

  // Do not inline expressions with side effects to prevent side-effect
  // reordering.
  if (expressionOp.hasSideEffects())
    return false;

  // Do not inline expressions with multiple uses.
  Value result = expressionOp.getResult();
  if (!result.hasOneUse())
    return false;

  Operation *user = *result.getUsers().begin();

  // Do not inline expressions used by operations with deferred emission, since
  // their translation requires the materialization of variables.
  if (hasDeferredEmission(user))
    return false;

  // Do not inline expressions used by ops with the CExpression trait. If this
  // was intended, the user could have been merged into the expression op.
  return !user->hasTrait<OpTrait::emitc::CExpression>();
}

static LogicalResult printConstantOp(CppEmitter &emitter, Operation *operation,
                                     Attribute value) {
  OpResult result = operation->getResult(0);

  // Only emit an assignment as the variable was already declared when printing
  // the FuncOp.
  if (emitter.shouldDeclareVariablesAtTop()) {
    // Skip the assignment if the emitc.constant has no value.
    if (auto oAttr = dyn_cast<emitc::OpaqueAttr>(value)) {
      if (oAttr.getValue().empty())
        return success();
    }

    if (failed(emitter.emitVariableAssignment(result)))
      return failure();
    return emitter.emitAttribute(operation->getLoc(), value);
  }

  // Emit a variable declaration for an emitc.constant op without value.
  if (auto oAttr = dyn_cast<emitc::OpaqueAttr>(value)) {
    if (oAttr.getValue().empty())
      // The semicolon gets printed by the emitOperation function.
      return emitter.emitVariableDeclaration(result,
                                             /*trailingSemicolon=*/false);
  }

  // Emit a variable declaration.
  if (failed(emitter.emitAssignPrefix(*operation)))
    return failure();
  return emitter.emitAttribute(operation->getLoc(), value);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::ConstantOp constantOp) {
  Operation *operation = constantOp.getOperation();
  Attribute value = constantOp.getValue();

  return printConstantOp(emitter, operation, value);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::VariableOp variableOp) {
  Operation *operation = variableOp.getOperation();
  Attribute value = variableOp.getValue();

  return printConstantOp(emitter, operation, value);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::GlobalOp globalOp) {

  return emitter.emitGlobalVariable(globalOp);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::AssignOp assignOp) {
  OpResult result = assignOp.getVar().getDefiningOp()->getResult(0);

  if (failed(emitter.emitVariableAssignment(result)))
    return failure();

  return emitter.emitOperand(assignOp.getValue());
}

// Process the builtin.unrealized_conversion_cast operation:
//   %0 = "builtin.unrealized_conversion_cast"(%1) : (index) -> i32
//   ->
//   %0 = %1; (%1 has been converted to i32)
static LogicalResult
printBuiltinUnrealizedConversionOp(CppEmitter &emitter,
                                   UnrealizedConversionCastOp operation) {
  if (failed(emitter.emitAssignPrefix(*operation)))
    return failure();
  raw_ostream &os = emitter.ostream();
  os << "(";
  if (failed(emitter.emitType(operation.getLoc(), operation.getResults()[0].getType())))
    return failure();
  os << ")";
  if (failed(emitter.emitOperands(*operation)))
    return failure();
  return success();
}

// For example, the gep operation:
//   %4 = llvm.getelementptr %0[%3] : (!llvm.ptr<1>, i64) -> !llvm.ptr<1>, f32
//   ->
//   __gm__ float *%4 = (__gm__ float *)%0 + %3;
static LogicalResult printLLVMGEPOp(CppEmitter &emitter,
                                    LLVM::GEPOp llvmGEPOp) {
  raw_ostream &os = emitter.ostream();

  // The following is same as: emitter.emitAssignPrefix(*operation);
  auto resultType = llvmGEPOp.getRes().getType();
  // The result of GEPOp must be a pointer type.
  if (auto ptrType = resultType.dyn_cast<LLVM::LLVMPointerType>()) {
    if (ptrType.isOpaque()) {
      // Add element type to the ptrType.
      if (!(llvmGEPOp.getElemType())) {
        return emitError(llvmGEPOp.getLoc(),
                         "ICT_ERROR(): llvm.getElementPtr has no elemType!");
      }
      ptrType = LLVM::LLVMPointerType::get(llvmGEPOp.getContext(),
                                           *(llvmGEPOp.getElemType()),
                                           ptrType.getAddressSpace());
    }
    if (failed(emitter.emitType(llvmGEPOp.getLoc(), ptrType)))
      return failure();

    os << " " << emitter.getOrCreateName(llvmGEPOp.getRes());
    os << " = ";
    // Here, has print: __gm__ float *%4 =

    os << "(";
    if (failed(emitter.emitType(llvmGEPOp.getLoc(), ptrType)))
      return failure();
    os << ") ";
    // Here, has print: __gm__ float *%4 = (__gm__ float *)

    if (failed(emitter.emitAddLikeOperands(*(llvmGEPOp.getOperation()))))
      return failure();
    // Here, has print: __gm__ float *%4 = (__gm__ float *)%0 + %3;

    return success();
  }
  return failure();
}

// Process the npu.mov_out_to_ub operation:
//   %5 = "npu.mov_out_to_ub"(%4) <{numElems = 8 : i32}> : (!llvm.ptr<1>) ->
//   vector<8xf32>
//   ->
//   copy_gm_to_ubuf((__ubuf__ float *)i5, (__gm__ float *)i4, 0, 1, 1, 0, 0);
//      (copy 8 elements from i4 to i5)
// copy_gm_to_ubuf(dst, src, 0, nburst, burstlen, srcstride, dststride)   
// I don't know the meaning of 1st immediate value, i.e. the '0'
//    burstlen: the number of chunks of 32Bytes(i.e. 256bits).
//    nburst, srcstride, dststride: default value is 1.
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MovOutToUBOp movOutToUBOp) {
  raw_ostream &os = emitter.ostream();
  os << "copy_gm_to_ubuf((__ubuf__ ";   // callee name

  auto movType = movOutToUBOp.getRes().getType();   // Res type is vector<Nxf32>
  // TODO: Here should modify emitType() to print VectorType, but it has no
  // addrspace info, so temporarily process it here.
  assert(isa<VectorType>(movType) &&
         "ICT_ERROR(): mov_out_to_ub's res type is not vector type!");
  auto vecType = movType.cast<VectorType>();

  auto elemType = vecType.getElementType();   // vector's element type, such as float
  if(failed(emitter.emitType(movOutToUBOp.getLoc(), elemType)))
    return failure();
  os << " *)";
  os << emitter.getOrCreateNameAlias(movOutToUBOp.getRes());
  // Here, has print: copy_gm_to_ubuf((__ubuf__ float *)i5, 

  os << ", (__gm__ ";
  if(failed(emitter.emitType(movOutToUBOp.getLoc(), elemType)))
    return failure();
  os << " *)";
  os << emitter.getOrCreateNameAlias(movOutToUBOp.getSrcAddr());
  // Here, has print: copy_gm_to_ubuf((__ubuf__ float *)i5, (__gm__ float *)i4,

  if (vecType.getShape().size() != 1) {
    return emitError(movOutToUBOp.getLoc(),
                     "ICT_ERROR(): mov_out_to_ub's res type is not 1D vector!");
  }
  auto numElems = vecType.getShape()[0];
  // NPU should has no basic type which size > float(i.e. 4 bytes), so here mod
  // 8 is enough.
  if (numElems % 8 != 0) {
    return emitError(movOutToUBOp.getLoc(),
                     "ICT_ERROR(): mov_out_to_ub's res type's numElems is not "
                     "multiple of 8!");
  }
  if(numElems > 256) {
    return emitError(movOutToUBOp.getLoc(),
                     "ICT_ERROR(): mov_out_to_ub's res type's numElems is larger "
                     "than 256!");
  }
  auto burstLen = numElems * elemType.getIntOrFloatBitWidth() / 256;
  os << ", 0, 1, " << burstLen << ", 0, 0)";
  // Here has print: 
  //   copy_gm_to_ubuf((__ubuf__ float *)i5, (__gm__ float *)i4, 0, 1, 1, 0, 0);
  return success();
}

// Process the npu.mov_ub_to_out operation:
// "npu.mov_ub_to_out"(%9, %8) <{numElems = 8 : i32}> : (!llvm.ptr<1>, vector<8xf32>) -> ()
// ->
// copy_ubuf_to_gm((__gm__ float *)i9, (__ubuf__ float *)i8, 0, 1, 1, 0, 0);
// The arguments of copy_ubuf_to_gm is the same as copy_gm_to_ubuf.
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MovUBToOutOp movUBToOUTOp) {
  raw_ostream &os = emitter.ostream();
  os << "copy_ubuf_to_gm((__gm__ ";   // callee name
  // get mov_ub_to_out's element type.
  auto movType = movUBToOUTOp.getValueToStore().getType();   // Res type is vector<Nxf32>
  assert(isa<VectorType>(movType) &&
         "ICT_ERROR(): mov_ub_to_out's res type is not vector type!");
  
  auto vecType = movType.cast<VectorType>();

  auto elemType = vecType.getElementType(); // vector's element type, such as float
  if(failed(emitter.emitType(movUBToOUTOp.getLoc(), elemType)))
    return failure();
  os << " *)";
  os << emitter.getOrCreateNameAlias(movUBToOUTOp.getDstAddr());
  // Here, has print: copy_ubuf_to_gm((__gm__ float *)i9,

  os << ", (__ubuf__ ";
  if(failed(emitter.emitType(movUBToOUTOp.getLoc(), elemType)))
    return failure();
  os << " *)";
  os << emitter.getOrCreateNameAlias(movUBToOUTOp.getValueToStore());
  // Here, has print: copy_ubuf_to_gm((__gm__ float *)i9, (__ubuf__ float *)i8,

  if (vecType.getShape().size() != 1) {
    return emitError(movUBToOUTOp.getLoc(),
                     "ICT_ERROR(): mov_ub_to_out's res type is not 1D vector!");
  }
  auto numElems = vecType.getShape()[0];
  // NPU should has no basic type which size > float(i.e. 4 bytes), so here mod
  // 8 is enough.
  if(numElems % 8 != 0) {
    return emitError(movUBToOUTOp.getLoc(),
                     "ICT_ERROR(): mov_ub_to_out's res type's numElems is not "
                     "multiple of 8!");
  }
  if(numElems > 256) {
    return emitError(movUBToOUTOp.getLoc(),
                     "ICT_ERROR(): mov_ub_to_out's res type's numElems is larger "
                     "than 256!");
  }
  auto burstLen = numElems * elemType.getIntOrFloatBitWidth() / 256;
  os << ", 0, 1, " << burstLen << ", 0, 0)";
  // Here has print:
  //   copy_ubuf_to_gm((__gm__ float *)i9, (__ubuf__ float *)i8, 0, 1, 1, 0, 0);
  return success();
}

// Process the npu.vadd operation:
// %8 = "npu.vadd"(%5, %7) <{numElems = 8 : i32}> : (vector<8xf32>,
// vector<8xf32>) -> vector<8xf32>
// ->
// vadd((__ubuf__ float *)i8, (__ubuf__ float *)i5, (__ubuf__ float *)i7, 1, 1,
// 1, 1, 8, 8, 8);
//    (add 8 elements from i5 and i7 to i8)
// 1, 1, 1, 1, 8, 8, 8
// uint8_t RepeatTime, uint8_t DstBlock, uint8_t SrcBlock0, uint8_t SrcBlock1,
// uint8_t DstStride, uint8_t SrcStride0, uint8_t SrcStride1
// repeat
// 1次，每次有8个32B，111代表这8个32B之间是连续的，888表示大片段之间是连续的
// vadd(dst, src1, src2, RepeatTime, DstBlock, SrcBlock0, SrcBlock1, DstStride,
//      SrcStride0, SrcStride1)
static LogicalResult printNPUOp(CppEmitter &emitter,
                                    npu::VAddF32Op vAddF32Op) {
  raw_ostream &os = emitter.ostream();
  os << "vadd(";   // callee name

  // TODO: using lambda function. This following lambda run crash.
  // print dst addr
  auto dstType = vAddF32Op.getRes().getType();
  assert(isa<VectorType>(dstType) &&
         "ICT_ERROR(): vadd's res type is not vector type!");
  auto dstVecType = dstType.cast<VectorType>();
  auto dstElemType = dstVecType.getElementType();   // vector's element type, such as float
  // vadd's addrsapce must be 6.
  auto dstPtrType = LLVM::LLVMPointerType::get(dstElemType, 6);
  os << "(";
  if(failed(emitter.emitType(vAddF32Op.getLoc(), dstPtrType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateNameAlias(vAddF32Op.getRes());
  os << ", ";
  // Here, has print: vadd((__ubuf__ float *)i8, 

  // print src1 addr
  auto src1Type = vAddF32Op.getLhs().getType();    // lhs type is vector<Nxf32>
  assert(isa<VectorType>(src1Type) &&
         "ICT_ERROR(): vadd's lhs type is not vector type!");
  auto src1VecType = src1Type.cast<VectorType>();
  auto src1ElemType = src1VecType.getElementType();   // vector's element type, such as float
  // vadd's addrsapce must be 6.
  auto src1PtrType = LLVM::LLVMPointerType::get(src1ElemType, 6);
  os << "(";
  if(failed(emitter.emitType(vAddF32Op.getLoc(), src1PtrType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateNameAlias(vAddF32Op.getLhs());
  os << ", ";
  // Here, has print: vadd((__ubuf__ float *)i8, (__ubuf__ float *)i5, 

  // print src2 addr
  auto src2Type = vAddF32Op.getRhs().getType();    // rhs type is vector<Nxf32>
  assert(isa<VectorType>(src2Type) &&
         "ICT_ERROR(): vadd's rhs type is not vector type!");
  auto src2VecType = src2Type.cast<VectorType>();
  auto src2ElemType = src2VecType.getElementType();   // vector's element type, such as float
  // vadd's addrsapce must be 6.
  auto src2PtrType = LLVM::LLVMPointerType::get(src2ElemType, 6);
  os << "(";
  if(failed(emitter.emitType(vAddF32Op.getLoc(), src2PtrType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateNameAlias(vAddF32Op.getRhs());
  os << ", ";
  // Here, has print: vadd((__ubuf__ float *)i8, (__ubuf__ float *)i5, (__ubuf__ float *)i7, 

  // print configs.
  auto numElems = vAddF32Op.getNumElems();
  if(numElems % 8 != 0) {
    return emitError(vAddF32Op.getLoc(),
                     "ICT_ERROR(): vadd's numElems is not multiple of 8!");
  }
  // auto dstElemType = vAddF32Op.getRes().getType().cast<VectorType>().getElementType();
  auto repeatTime = numElems * dstElemType.getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 1, 1, 8, 8, 8)";
  // Here has print:
  //  vadd((__ubuf__ float *)i8, (__ubuf__ float *)i5, (__ubuf__ float *)i7, 1, 1, 1, 1, 8, 8, 8);
  return success();
}

// Process the npu.vadd_i32 operation:
// %27 = "npu.vadd_i32"(%26, %18) <{numElems = 8 : i32}> : (vector<8xi32>, vector<8xi32>) -> vector<8xi32>
// ->
// vadd((__ubuf__ int32_t *)i27, (__ubuf__ int32_t *)i26, (__ubuf__ int32_t *)i18, 1, 1, 1, 1, 8, 8, 8);

// uint8_t RepeatTime, uint8_t DstBlock, uint8_t SrcBlock0, uint8_t SrcBlock1,
// uint8_t DstStride, uint8_t SrcStride0, uint8_t SrcStride1
// repeat
// 1次, 每次有8个32B, 111代表这8个32B之间是连续的, 888表示大片段之间是连续的
// vadd(dst, src1, src2, RepeatTime, DstBlock, SrcBlock0, SrcBlock1, DstStride,
//      SrcStride0, SrcStride1)


static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::VAddI32Op vAddI32Op) {
  raw_ostream &os = emitter.ostream();
  os << "vadd(";   // callee name

  // print dst addr
  auto dstType = vAddI32Op.getRes().getType();
  assert(isa<VectorType>(dstType) &&
         "ICT_ERROR(): vadd_i32's res type is not vector type!");
  auto dstVecType = dstType.cast<VectorType>();
  
  os << "(";
  if(failed(emitter.emitType(vAddI32Op.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vAddI32Op.getRes());
  os << ", ";
  // Here, has print: vadd((__ubuf__ int32_t *)i27, 

  // TODO: 这里的 type其实重叠了，src1和src2不用再提取type的，因为必须得和dst一样。
  // print src1 addr
  os << "(";
  if(failed(emitter.emitType(vAddI32Op.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vAddI32Op.getLhs());
  os << ", ";
  // Here, has print: vadd((__ubuf__ int32_t *)i27, (__ubuf__ int32_t *)i26, 

  // print src2 addr
  os << "(";
  if(failed(emitter.emitType(vAddI32Op.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vAddI32Op.getRhs());
  os << ", ";
  // Here, has print: vadd((__ubuf__ int32_t *)i27, (__ubuf__ int32_t *)i26, (__ubuf__ int32_t *)i18,

  // print configs.
  auto numElems = vAddI32Op.getNumElems();
  if(numElems % 8 != 0) {
    return emitError(vAddI32Op.getLoc(),
                     "ICT_ERROR(): vadd_i32's numElems is not multiple of 8!");
  }
  auto dstElemType = dstVecType.getElementType();   // vector's element type, such as int32_t
  auto repeatTime = numElems * dstElemType.getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 1, 1, 8, 8, 8)";
  // Here has print:
  //  vadd((__ubuf__ int32_t *)i27, (__ubuf__ int32_t *)i26, (__ubuf__ int32_t *)i18, 1, 1, 1, 1, 8, 8, 8);
  return success();
}

// Process the npu.vmul_f32 operation:
// %77 = "npu.vmul_f32"(%76, %56) <{numElems = 8 : i32}> : (vector<8xf32>, vector<8xf32>) -> vector<8xf32>
// ->
// vmul((__ubuf__ float *)i_8, (__ubuf__ float *)i_7, (__ubuf__ float *)i_5, 1, 1, 1, 1, 8, 8, 8);
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::VMulF32Op vMulF32Op) {
  raw_ostream &os = emitter.ostream();
  os << "vmul(";   // callee name

  // print dst addr
  auto dstType = vMulF32Op.getRes().getType();
  assert(isa<VectorType>(dstType) &&
         "ICT_ERROR(): vmul_f32's res type is not vector type!");
  auto dstVecType = dstType.cast<VectorType>();
  os << "(";
  if(failed(emitter.emitType(vMulF32Op.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vMulF32Op.getRes());
  os << ", ";
  // Here, has print: vmul((__ubuf__ float *)i_8, 

  // print src1 addr
  os << "(";
  if(failed(emitter.emitType(vMulF32Op.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vMulF32Op.getLhs());
  os << ", ";
  // Here, has print: vmul((__ubuf__ float *)i_8, (__ubuf__ float *)i_7, 

  // print src2 addr
  os << "(";
  if(failed(emitter.emitType(vMulF32Op.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vMulF32Op.getRhs());
  os << ", ";
  // Here, has print: vmul((__ubuf__ float *)i_8, (__ubuf__ float *)i_7, (__ubuf__ float *)i_5,

  // print configs.
  auto numElems = vMulF32Op.getNumElems();
  if(numElems % 8 != 0) {
    return emitError(vMulF32Op.getLoc(),
                     "ICT_ERROR(): vmul_f32's numElems is not multiple of 8!");
  }
  auto repeatTime = numElems * dstVecType.getElementType().getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 1, 1, 8, 8, 8)";
  // Here has print:
  //  vmul((__ubuf__ float *)i_8, (__ubuf__ float *)i_7, (__ubuf__ float *)i_5, 1, 1, 1, 1, 8, 8, 8);
  return success();
}







// Process the npu.vcmp_i32 operation:
// %29 = "npu.vcmp_i32"(%28, %18) <{predicate = 0 : i64}> : (vector<8xi32>, vector<8xi32>) -> vector<8xi1>
// ->
// vcmpv_eq((__ubuf__ uint8_t *)i29, (__ubuf__ int32_t *)i28, (__ubuf__ int32_t *)i18, 1, 1, 1, 1, 8, 8, 8);

// void vcmpv_eq(__ubuf__ uint8_t* dst, __ubuf__ int32_t* src0, __ubuf__
// int32_t* src1, uint8_t repeat, uint8_t dstBlockStride, uint8_t
// src0BlockStride, uint8_t src1BlockStride, uint8_t dstRepeatStride, uint8_t
// src0RepeatStride, uint8_t src1RepeatStride);
static LogicalResult printNPUOp(CppEmitter &emitter, npu::VCmpI32Op vCmpI32Op) {
  auto pred = vCmpI32Op.getPredicate();
  if(pred != npu::NPUCmpIPredicate::eq) {
    llvm::errs() << "ICT_ERROR(): vcmp_i32's predicate is not 0! can not "
                    "process! Ascend can only compare eq for i32\n";
    exit(-1);
  }

  raw_ostream &os = emitter.ostream();
  os << "vcmpv_eq((__ubuf__ uint8_t *)";   // callee name
  // print dst addr
  os << emitter.getOrCreateName(vCmpI32Op.getRes());
  os << ", ";
  // Here, has print: vcmpv_eq((__ubuf__ uint8_t *)i29, 

  // print src1 addr
  // TODO: 或许这里的operand的输出，可以用专门的翻译operand的函数来实现，应该可以简化一些。
  auto src1Type = vCmpI32Op.getLhs().getType();    // lhs type is vector<Nxi32>
  assert(isa<VectorType>(src1Type) &&
         "ICT_ERROR(): vcmp_i32's lhs type is not vector type!");
  auto src1VecType = src1Type.cast<VectorType>();
  
  os << "(";
  if(failed(emitter.emitType(vCmpI32Op.getLoc(), src1VecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vCmpI32Op.getLhs());
  os << ", ";
  // Here, has print: vcmpv_eq((__ubuf__ uint8_t *)i29, (__ubuf__ int32_t *)i28, 

  // print src2 addr
  os << "(";
  if(failed(emitter.emitType(vCmpI32Op.getLoc(), src1VecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vCmpI32Op.getRhs());
  os << ", ";
  // Here, has print: vcmpv_eq((__ubuf__ uint8_t *)i29, (__ubuf__ int32_t *)i28, (__ubuf__ int32_t *)i18,

  // print configs.
  auto numElems = src1VecType.getShape()[0];
  if(numElems % 8 != 0) {
    return emitError(vCmpI32Op.getLoc(),
                     "ICT_ERROR(): vcmp_i32's numElems is not multiple of 8!");
  }
  auto src1ElemType = src1VecType.getElementType();   // vector's element type, such as i32
  auto repeatTime = numElems * src1ElemType.getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 1, 1, 8, 8, 8)";
  // Here has print:
  //  vcmpv_eq((__ubuf__ uint8_t *)i29, (__ubuf__ int32_t *)i28, (__ubuf__ int32_t *)i18, 1, 1, 1, 1, 8, 8, 8);
  return success();
}

// Process the npu.vsel operation:
// %56 = "npu.vsel"(%29, %55, %19) <{numElems = 8 : i32}> : (vector<8xi1>, vector<8xf32>, vector<8xf32>) -> vector<8xf32>
// ->
// set_cmpmask((__ubuf__ uint8_t *)i29);
// set_mask_norm();
// set_vector_mask(0x0, 0xff);
// vsel((__ubuf__ float *)i56, (__ubuf__ float *)i55, (__ubuf__ float *)i19, 1, 1, 1, 1, 8, 8, 8);
// set_vector_mask(0xffffffffffffffff, 0xffffffffffffffff);
// 后面那个set_vector_mask是否是否需要，我记不太清了...后面测试的时候再说；前面那个mask是否需要专门为了vsel而设置，我也记不太清了...所以先按没有vec_mask来走吧；
static LogicalResult printNPUOp(CppEmitter &emitter, npu::VSelOp vSelOp) {
  raw_ostream &os = emitter.ostream();
  os << "set_cmpmask((__ubuf__ uint8_t *)";   // callee name
  // print cmpmask addr
  os << emitter.getOrCreateName(vSelOp.getMask());
  os << ");\n";
  // Here, has print: set_cmpmask((__ubuf__ uint8_t *)i29;

  // TODO: 考虑一下设置vector mask？
  // os << "set_mask_norm();\n";
  // os << "set_vector_mask(0x0, 0xff);\n";
  // // Here, has print: set_mask_norm(); set_vector_mask(0x0, 0xff);

  os << "vsel((__ubuf__ float *)";   // callee name
  // print dst addr
  auto dstType = vSelOp.getRes().getType();
  assert(isa<VectorType>(dstType) &&
         "ICT_ERROR(): vsel's res type is not vector type!");
  auto dstVecType = dstType.cast<VectorType>();
  
  os << "(";
  if(failed(emitter.emitType(vSelOp.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vSelOp.getRes());
  os << ", ";
  // Here, has print: vsel((__ubuf__ float *)i56, 

  // print src1 addr
  os << "(";
  if(failed(emitter.emitType(vSelOp.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vSelOp.getLhs());
  os << ", ";
  // Here, has print: vsel((__ubuf__ float *)i56, (__ubuf__ float *)i55,

  // print src2 addr
  os << "(";
  if(failed(emitter.emitType(vSelOp.getLoc(), dstVecType)))
    return failure();
  os << " )";
  os << emitter.getOrCreateName(vSelOp.getRhs());
  os << ", ";
  // Here, has print: vsel((__ubuf__ float *)i56, (__ubuf__ float *)i55, (__ubuf__ float *)i19,

  // print configs.
  auto numElems = dstVecType.getShape()[0];
  if(numElems % 8 != 0) {
    return emitError(vSelOp.getLoc(),
                     "ICT_ERROR(): vsel's numElems is not multiple of 8!");
  }
  auto dstElemType = dstVecType.getElementType();   // vector's element type, such as float
  auto repeatTime = numElems * dstElemType.getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 1, 1, 8, 8, 8)";
  // Here has print:
  //  vsel((__ubuf__ float *)i56, (__ubuf__ float *)i55, (__ubuf__ float *)i19, 1, 1, 1, 1, 8, 8, 8);
  return success();
}







// Process the npu.broadcast_i32 operation:
// %2 = "npu.broadcast_i32"(%c32_i32) <{numElems = 8 : i32}> : (i32) -> vector<8xi32>
// ->
// vector_dup((__ubuf__ int32_t *)i_4_arg3_vec, i_arg3, 1, 1, 0, 8, 0);
// 1, 1, 0, 8, 0:
// uint8_t repeat, uint16_t dstBlockStride, uint16_t srcBlockStride, 
// uint8_t dstRepeatStride, uint8_t srcRepeatStride
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::BroadCastI32Op broadcastI32Op) {
  raw_ostream &os = emitter.ostream();
  os << "vector_dup((__ubuf__ int32_t *)";
  auto dstType = broadcastI32Op.getRes().getType();
  assert(isa<VectorType>(dstType) &&
         "ICT_ERROR(): broadcast_i32's res type is not vector type!");
  auto vecType = dstType.cast<VectorType>();
  auto elemType = vecType.getElementType();   // vector's element type, such as int32_t
  os << emitter.getOrCreateName(broadcastI32Op.getRes());
  os << ", ";
  os << emitter.getOrCreateName(broadcastI32Op.getScalar());
  auto numElems = broadcastI32Op.getNumElems();
  if(numElems % 8 != 0) {
    return emitError(broadcastI32Op.getLoc(),
                     "ICT_ERROR(): broadcast_i32's numElems is not multiple of 8!");
  }
  // TODO: 这里这个repeatTime的计算，难道也得体现在生成的cce程序中吗？
  auto repeatTime = numElems * elemType.getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 0, 8, 0)";
  return success();
}

// Process the npu.movev_f32 operation:
// %4 = "npu.movev_f32"(%cst) <{numElems = 8 : i32}> : (f32) -> vector<8xf32>
// ->
// vector_dup((__ubuf__ float *)i_cst_0, %cst, 1, 1, 0, 8, 0);
// 实际上，这个的处理和BroadCastI32Op的处理是一样的，只是类型从i32换成了f32
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MOVEVF32Op moveVF32Op) {
  raw_ostream &os = emitter.ostream();
  os << "vector_dup((__ubuf__ float *)";
  auto dstType = moveVF32Op.getRes().getType();
  assert(isa<VectorType>(dstType) &&
         "ICT_ERROR(): movev_f32's res type is not vector type!");
  auto vecType = dstType.cast<VectorType>();
  auto elemType = vecType.getElementType();   // vector's element type, such as float
  os << emitter.getOrCreateName(moveVF32Op.getRes());
  os << ", ";
  os << emitter.getOrCreateName(moveVF32Op.getScalar());
  auto numElems = moveVF32Op.getNumElems();
  if(numElems % 8 != 0) {
    return emitError(moveVF32Op.getLoc(),
                     "ICT_ERROR(): movev_f32's numElems is not multiple of 8!");
  }
  // TODO: 这里这个repeatTime的计算，难道也得体现在生成的cce程序中吗？不对吧，这里这个repeatTime应该是编译时已知的吧；而且在这里就是个unsigned int，应该是可以直接输出为数字的。
  auto repeatTime = numElems * elemType.getIntOrFloatBitWidth() / 256;
  os << repeatTime << ", 1, 0, 8, 0)";
  return success();
}

// Process the npu.atomic_add_f32 operation:
// "npu.atomic_add_f32"(%53, %36) <{numElems = 8 : i32}> : (!llvm.ptr<1>, vector<8xf32>) -> ()
// ->
// set_atomic_add();
// set_atomic_f32();
// copy_ubuf_to_gm((__gm__ void*)i_arg1_4, (__ubuf__ void*)i_cst_0, 0, 1, 1, 0, 0);
// set_atomic_none();

// void copy_ubuf_to_gm(__gm__ void* dst, __ubuf__ void* src, uint8_t sid,
// uint16_t nBurst, uint16_t lenBurst, uint16_t srcStride, uint16_t dstStride);
// nBurst: 数据块的数量
// lenBurst: 每个数据块的长度(以32 bytes为单位)
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::AtomicAddF32Op atomicAddF32Op) {
  raw_ostream &os = emitter.ostream();
  os << "set_atomic_add();\n";
  os << "set_atomic_f32();\n";
  os << "copy_ubuf_to_gm((__gm__ void*)";
  auto dstType = atomicAddF32Op.getDstAddr().getType();
  assert(isa<LLVM::LLVMPointerType>(dstType) &&
         "ICT_ERROR(): atomic_add_f32's dst type is not llvm.ptr<1> type!");
  os << emitter.getOrCreateName(atomicAddF32Op.getDstAddr());
  os << ", (__ubuf__ void*)";
  auto srcType = atomicAddF32Op.getValueToAdd().getType();
  assert(isa<VectorType>(srcType) &&
         "ICT_ERROR(): atomic_add_f32's src type is not vector type!");
  os << emitter.getOrCreateName(atomicAddF32Op.getValueToAdd());

  // compute config value
  unsigned sid = 0;
  unsigned numElem = atomicAddF32Op.getNumElems();
  if(numElem % 8 != 0) {
    return emitError(atomicAddF32Op.getLoc(),
                     "ICT_ERROR(): atomic_add_f32's numElems is not multiple of 8!");
  }
  unsigned nBurst = 1;
  unsigned lenBurst = numElem * sizeof(float) / 32;
  os << ", " << sid << ", " << nBurst << ", " << lenBurst << ", 0, 0);\n";
  os << "set_atomic_none();";
  return success();
}











// Process the npu.assign_ub_i32 operation:
// "npu.assign_ub_i32"(%3) <{index = 0 : i32, srcScalar = 0 : i32}> : (vector<8xi32>) -> ()
// ->
// *((__ubuf__ int32_t *)i_cst_1 + 0) = 0;  // 这里的0为常量，比如说，可以为0-7等等
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::AssignUBI32Op assignUBI32Op) {
  raw_ostream &os = emitter.ostream();
  os << "*((__ubuf__ int32_t *)";
  auto dstVectorType = assignUBI32Op.getDstVector().getType();
  assert(isa<VectorType>(dstVectorType) &&
         "ICT_ERROR(): assign_ub_i32's dst type is not vector type!");
  os << emitter.getOrCreateName(assignUBI32Op.getDstVector());
  os << " + ";
  os << assignUBI32Op.getIndex();
  os << ") = ";
  os << assignUBI32Op.getSrcScalar();
  return success();
}

// Process the npu.load_ub_i32 operation:
// %29 = "npu.load_ub_i32"(%27) <{index = 0 : i32}> : (vector<8xi32>) -> i32
// ->
// int32_t i = *((__ubuf__ int32_t *)i27 + 0);
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::LoadUBI32Op loadUBI32Op) {
  raw_ostream &os = emitter.ostream();
  os << "int32_t ";
  os << emitter.getOrCreateName(loadUBI32Op.getRes());
  os << " = *((__ubuf__ int32_t *)";
  auto srcVectorType = loadUBI32Op.getSrcVector().getType();
  assert(isa<VectorType>(srcVectorType) &&
         "ICT_ERROR(): load_ub_i32's src type is not vector type!");
  os << emitter.getOrCreateName(loadUBI32Op.getSrcVector());
  os << " + ";
  os << loadUBI32Op.getIndex();
  os << ");";
  return success();
}

// Process the npu.store_ub_i32 operation:
// "npu.store_ub_i32"(%28, %31) <{index = 0 : i32}> : (vector<8xi32>, i32) -> ()
// ->
// *((__ubuf__ int32_t *)i28 + 0) = i31;
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::StoreUBI32Op storeUBI32Op) {
  raw_ostream &os = emitter.ostream();
  os << "*((__ubuf__ int32_t *)";
  auto dstVectorType = storeUBI32Op.getDstVector().getType();
  assert(isa<VectorType>(dstVectorType) &&
         "ICT_ERROR(): store_ub_i32's dst type is not vector type!");
  os << emitter.getOrCreateName(storeUBI32Op.getDstVector());
  os << " + ";
  os << storeUBI32Op.getIndex();
  os << ") = ";
  os << emitter.getOrCreateName(storeUBI32Op.getSrcScalar());
  return success();
}

// TODO: 这里是暂时这样的，为了让代码先暂时跑起来的暂时措施，真正的应该是：根据npu.alloca_ub_vector去分配内存，然后得到npu.alloca_ub_vector_addr(带地址参数的)，然后转换为get_imm(addr).
// Process the npu.alloca_ub_vector operation:
// %28 = "npu.alloca_ub_vector"() <{numElems = 8 : i32}> : () -> vector<8xi32>
// ->
// __ubuf__  uint8_t *%28 = (__ubuf__  uint8_t *)get_imm();
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::AllocaUBVectorOp allocaUBVectorOp) {
  raw_ostream &os = emitter.ostream();
  os << "__ubuf__  uint8_t *";
  os << emitter.getOrCreateName(allocaUBVectorOp.getRes());
  os << " = (__ubuf__  uint8_t *)get_imm();";
  return success();
}

// Process the npu.block_id operation:
// %5 = "npu.block_id"() : () -> i64
// ->
// int32_t i0_block_idx = get_block_idx();
static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::BlockIdOp blockIdOp) {
  raw_ostream &os = emitter.ostream();
  os << "int32_t ";
  os << emitter.getOrCreateName(blockIdOp.getRes());
  os << " = get_block_idx();";
  return success();
}

// Process the memref.load operation:
// %55 = memref.load %arg0[%arg4] : memref<?xf32>
// ->
// float input_data = (__gm__ float *)gm_input[i_arg4];
static LogicalResult printMemRefOp(CppEmitter &emitter, memref::LoadOp loadOp) {
  raw_ostream &os = emitter.ostream();
  if (failed(emitter.emitAssignPrefix(*loadOp)))
    return failure();
  if (failed(emitter.emitType(loadOp.getLoc(), loadOp.getMemRefType())))
    return failure();
  os << " ";
  os << emitter.getOrCreateName(loadOp.getMemRef());
  os << "[";
  if (failed(emitter.emitOperand(loadOp.getIndices()[0])))
    return failure();
  os << "]";
  return success();
}






static LogicalResult printOperation(CppEmitter &emitter, emitc::LoadOp loadOp) {
  if (failed(emitter.emitAssignPrefix(*loadOp)))
    return failure();

  return emitter.emitOperand(loadOp.getOperand());
}

static LogicalResult printNPUOp(CppEmitter &emitter, npu::AllocaAddr op) {
  auto Op = op.getOperation();
  auto AllocationIndex =
      Op->getAttrOfType<IntegerAttr>("ub-allocation-index").getInt();
  auto &&AllocaRes = op.getVec();
  emitter.AllocationMap[AllocationIndex] = AllocaRes;

  raw_ostream &os = emitter.ostream();

  os << "__ubuf__  uint8_t *";
  os << emitter.getOrCreateName(AllocaRes);
  os << " = (__ubuf__ uint8_t *)get_imm(";
  os << op.getNumOffset();
  os << ")";

  return success();
}

static LogicalResult printBinaryOperation(CppEmitter &emitter,
                                          Operation *operation,
                                          StringRef binaryOperator) {
  raw_ostream &os = emitter.ostream();

  if (failed(emitter.emitAssignPrefix(*operation)))
    return failure();

  if (failed(emitter.emitOperand(operation->getOperand(0))))
    return failure();

  os << " " << binaryOperator << " ";

  if (failed(emitter.emitOperand(operation->getOperand(1))))
    return failure();

  return success();
}

static LogicalResult printUnaryOperation(CppEmitter &emitter,
                                         Operation *operation,
                                         StringRef unaryOperator) {
  raw_ostream &os = emitter.ostream();

  if (failed(emitter.emitAssignPrefix(*operation)))
    return failure();

  os << unaryOperator;

  if (failed(emitter.emitOperand(operation->getOperand(0))))
    return failure();

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::AddOp addOp) {
  Operation *operation = addOp.getOperation();

  return printBinaryOperation(emitter, operation, "+");
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::DivOp divOp) {
  Operation *operation = divOp.getOperation();

  return printBinaryOperation(emitter, operation, "/");
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::MulOp mulOp) {
  Operation *operation = mulOp.getOperation();

  return printBinaryOperation(emitter, operation, "*");
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::RemOp remOp) {
  Operation *operation = remOp.getOperation();

  return printBinaryOperation(emitter, operation, "%");
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::SubOp subOp) {
  Operation *operation = subOp.getOperation();

  return printBinaryOperation(emitter, operation, "-");
}

static LogicalResult emitSwitchCase(CppEmitter &emitter,
                                    raw_indented_ostream &os, Region &region) {
  for (Region::OpIterator iteratorOp = region.op_begin(), end = region.op_end();
       std::next(iteratorOp) != end; ++iteratorOp) {
    if (failed(emitter.emitOperation(*iteratorOp, /*trailingSemicolon=*/true)))
      return failure();
  }
  os << "break;\n";
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::SwitchOp switchOp) {
  raw_indented_ostream &os = emitter.ostream();

  os << "switch (";
  if (failed(emitter.emitOperand(switchOp.getArg())))
    return failure();
  os << ") {";

  for (auto pair : llvm::zip(switchOp.getCases(), switchOp.getCaseRegions())) {
    os << "\ncase " << std::get<0>(pair) << ": {\n";
    os.indent();

    if (failed(emitSwitchCase(emitter, os, std::get<1>(pair))))
      return failure();

    os.unindent() << "}";
  }

  os << "\ndefault: {\n";
  os.indent();

  if (failed(emitSwitchCase(emitter, os, switchOp.getDefaultRegion())))
    return failure();

  os.unindent() << "}\n}";
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::CmpOp cmpOp) {
  Operation *operation = cmpOp.getOperation();

  StringRef binaryOperator;

  switch (cmpOp.getPredicate()) {
  case emitc::CmpPredicate::eq:
    binaryOperator = "==";
    break;
  case emitc::CmpPredicate::ne:
    binaryOperator = "!=";
    break;
  case emitc::CmpPredicate::lt:
    binaryOperator = "<";
    break;
  case emitc::CmpPredicate::le:
    binaryOperator = "<=";
    break;
  case emitc::CmpPredicate::gt:
    binaryOperator = ">";
    break;
  case emitc::CmpPredicate::ge:
    binaryOperator = ">=";
    break;
  case emitc::CmpPredicate::three_way:
    binaryOperator = "<=>";
    break;
  }

  return printBinaryOperation(emitter, operation, binaryOperator);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::ConditionalOp conditionalOp) {
  raw_ostream &os = emitter.ostream();

  if (failed(emitter.emitAssignPrefix(*conditionalOp)))
    return failure();

  if (failed(emitter.emitOperand(conditionalOp.getCondition())))
    return failure();

  os << " ? ";

  if (failed(emitter.emitOperand(conditionalOp.getTrueValue())))
    return failure();

  os << " : ";

  if (failed(emitter.emitOperand(conditionalOp.getFalseValue())))
    return failure();

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::VerbatimOp verbatimOp) {
  raw_ostream &os = emitter.ostream();

  FailureOr<SmallVector<ReplacementItem>> items =
      verbatimOp.parseFormatString();
  if (failed(items))
    return failure();

  auto fmtArg = verbatimOp.getFmtArgs().begin();

  for (ReplacementItem &item : *items) {
    if (auto *str = std::get_if<StringRef>(&item)) {
      os << *str;
    } else {
      if (failed(emitter.emitOperand(*fmtArg++)))
        return failure();
    }
  }

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    cf::BranchOp branchOp) {
  raw_ostream &os = emitter.ostream();
  Block &successor = *branchOp.getSuccessor();

  for (auto pair :
       llvm::zip(branchOp.getOperands(), successor.getArguments())) {
    Value &operand = std::get<0>(pair);
    BlockArgument &argument = std::get<1>(pair);
    os << emitter.getOrCreateName(argument) << " = "
       << emitter.getOrCreateName(operand) << ";\n";
  }

  os << "goto ";
  if (!(emitter.hasBlockLabel(successor)))
    return branchOp.emitOpError("unable to find label for successor block");
  os << emitter.getOrCreateName(successor);
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    cf::CondBranchOp condBranchOp) {
  raw_indented_ostream &os = emitter.ostream();
  Block &trueSuccessor = *condBranchOp.getTrueDest();
  Block &falseSuccessor = *condBranchOp.getFalseDest();

  os << "if (";
  if (failed(emitter.emitOperand(condBranchOp.getCondition())))
    return failure();
  os << ") {\n";

  os.indent();

  // If condition is true.
  for (auto pair : llvm::zip(condBranchOp.getTrueOperands(),
                             trueSuccessor.getArguments())) {
    Value &operand = std::get<0>(pair);
    BlockArgument &argument = std::get<1>(pair);
    os << emitter.getOrCreateName(argument) << " = "
       << emitter.getOrCreateName(operand) << ";\n";
  }

  os << "goto ";
  if (!(emitter.hasBlockLabel(trueSuccessor))) {
    return condBranchOp.emitOpError("unable to find label for successor block");
  }
  os << emitter.getOrCreateName(trueSuccessor) << ";\n";
  os.unindent() << "} else {\n";
  os.indent();
  // If condition is false.
  for (auto pair : llvm::zip(condBranchOp.getFalseOperands(),
                             falseSuccessor.getArguments())) {
    Value &operand = std::get<0>(pair);
    BlockArgument &argument = std::get<1>(pair);
    os << emitter.getOrCreateName(argument) << " = "
       << emitter.getOrCreateName(operand) << ";\n";
  }

  os << "goto ";
  if (!(emitter.hasBlockLabel(falseSuccessor))) {
    return condBranchOp.emitOpError()
           << "unable to find label for successor block";
  }
  os << emitter.getOrCreateName(falseSuccessor) << ";\n";
  os.unindent() << "}";
  return success();
}

static LogicalResult printCallOperation(CppEmitter &emitter, Operation *callOp,
                                        StringRef callee) {
  if (failed(emitter.emitAssignPrefix(*callOp)))
    return failure();

  raw_ostream &os = emitter.ostream();
  os << callee << "(";
  if (failed(emitter.emitOperands(*callOp)))
    return failure();
  os << ")";
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, func::CallOp callOp) {
  Operation *operation = callOp.getOperation();
  StringRef callee = callOp.getCallee();

  return printCallOperation(emitter, operation, callee);
}

// static LogicalResult printOperation(CppEmitter &emitter, emitc::CallOp callOp) {
//   Operation *operation = callOp.getOperation();
//   StringRef callee = callOp.getCallee();

//   return printCallOperation(emitter, operation, callee);
// }

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::CallOpaqueOp callOpaqueOp) {
  raw_ostream &os = emitter.ostream();
  Operation &op = *callOpaqueOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();
  os << callOpaqueOp.getCallee();

  auto emitArgs = [&](Attribute attr) -> LogicalResult {
    if (auto t = dyn_cast<IntegerAttr>(attr)) {
      // Index attributes are treated specially as operand index.
      if (t.getType().isIndex()) {
        int64_t idx = t.getInt();
        Value operand = op.getOperand(idx);
        if (!emitter.hasValueInScope(operand))
          return op.emitOpError("operand ")
                 << idx << "'s value not defined in scope";
        os << emitter.getOrCreateName(operand);
        return success();
      }
    }
    if (failed(emitter.emitAttribute(op.getLoc(), attr)))
      return failure();

    return success();
  };

  if (callOpaqueOp.getTemplateArgs()) {
    os << "<";
    if (failed(interleaveCommaWithError(*callOpaqueOp.getTemplateArgs(), os,
                                        emitArgs)))
      return failure();
    os << ">";
  }

  os << "(";

  LogicalResult emittedArgs =
      callOpaqueOp.getArgs()
          ? interleaveCommaWithError(*callOpaqueOp.getArgs(), os, emitArgs)
          : emitter.emitOperands(op);
  if (failed(emittedArgs))
    return failure();
  os << ")";
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::ApplyOp applyOp) {
  raw_ostream &os = emitter.ostream();
  Operation &op = *applyOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();
  os << applyOp.getApplicableOperator();
  os << emitter.getOrCreateName(applyOp.getOperand());

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::BitwiseAndOp bitwiseAndOp) {
  Operation *operation = bitwiseAndOp.getOperation();
  return printBinaryOperation(emitter, operation, "&");
}

static LogicalResult
printOperation(CppEmitter &emitter,
               emitc::BitwiseLeftShiftOp bitwiseLeftShiftOp) {
  Operation *operation = bitwiseLeftShiftOp.getOperation();
  return printBinaryOperation(emitter, operation, "<<");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::BitwiseNotOp bitwiseNotOp) {
  Operation *operation = bitwiseNotOp.getOperation();
  return printUnaryOperation(emitter, operation, "~");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::BitwiseOrOp bitwiseOrOp) {
  Operation *operation = bitwiseOrOp.getOperation();
  return printBinaryOperation(emitter, operation, "|");
}

static LogicalResult
printOperation(CppEmitter &emitter,
               emitc::BitwiseRightShiftOp bitwiseRightShiftOp) {
  Operation *operation = bitwiseRightShiftOp.getOperation();
  return printBinaryOperation(emitter, operation, ">>");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::BitwiseXorOp bitwiseXorOp) {
  Operation *operation = bitwiseXorOp.getOperation();
  return printBinaryOperation(emitter, operation, "^");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::UnaryPlusOp unaryPlusOp) {
  Operation *operation = unaryPlusOp.getOperation();
  return printUnaryOperation(emitter, operation, "+");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::UnaryMinusOp unaryMinusOp) {
  Operation *operation = unaryMinusOp.getOperation();
  return printUnaryOperation(emitter, operation, "-");
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::CastOp castOp) {
  raw_ostream &os = emitter.ostream();
  Operation &op = *castOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();
  os << "(";
  if (failed(emitter.emitType(op.getLoc(), op.getResult(0).getType())))
    return failure();
  os << ") ";
  return emitter.emitOperand(castOp.getOperand());
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::ExpressionOp expressionOp) {
  if (shouldBeInlined(expressionOp))
    return success();

  Operation &op = *expressionOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();

  return emitter.emitExpression(expressionOp);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::IncludeOp includeOp) {
  raw_ostream &os = emitter.ostream();

  os << "#include ";
  if (includeOp.getIsStandardInclude())
    os << "<" << includeOp.getInclude() << ">";
  else
    os << "\"" << includeOp.getInclude() << "\"";

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::LogicalAndOp logicalAndOp) {
  Operation *operation = logicalAndOp.getOperation();
  return printBinaryOperation(emitter, operation, "&&");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::LogicalNotOp logicalNotOp) {
  Operation *operation = logicalNotOp.getOperation();
  return printUnaryOperation(emitter, operation, "!");
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::LogicalOrOp logicalOrOp) {
  Operation *operation = logicalOrOp.getOperation();
  return printBinaryOperation(emitter, operation, "||");
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::ForOp forOp) {

  raw_indented_ostream &os = emitter.ostream();

  // Utility function to determine whether a value is an expression that will be
  // inlined, and as such should be wrapped in parentheses in order to guarantee
  // its precedence and associativity.
  auto requiresParentheses = [&](Value value) {
    auto expressionOp =
        dyn_cast_if_present<ExpressionOp>(value.getDefiningOp());
    if (!expressionOp)
      return false;
    return shouldBeInlined(expressionOp);
  };

  os << "for (";
  if (failed(
          emitter.emitType(forOp.getLoc(), forOp.getInductionVar().getType())))
    return failure();
  os << " ";
  os << emitter.getOrCreateName(forOp.getInductionVar());
  os << " = ";
  if (failed(emitter.emitOperand(forOp.getLowerBound())))
    return failure();
  os << "; ";
  os << emitter.getOrCreateName(forOp.getInductionVar());
  os << " < ";
  Value upperBound = forOp.getUpperBound();
  bool upperBoundRequiresParentheses = requiresParentheses(upperBound);
  if (upperBoundRequiresParentheses)
    os << "(";
  if (failed(emitter.emitOperand(upperBound)))
    return failure();
  if (upperBoundRequiresParentheses)
    os << ")";
  os << "; ";
  os << emitter.getOrCreateName(forOp.getInductionVar());
  os << " += ";
  if (failed(emitter.emitOperand(forOp.getStep())))
    return failure();
  os << ") {\n";
  os.indent();

  Region &forRegion = forOp.getRegion();
  auto regionOps = forRegion.getOps();

  // We skip the trailing yield op.
  for (auto it = regionOps.begin(); std::next(it) != regionOps.end(); ++it) {
    if (failed(emitter.emitOperation(*it, /*trailingSemicolon=*/true)))
      return failure();
  }

  os.unindent() << "}";

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, scf::ForOp forOp) {

  raw_indented_ostream &os = emitter.ostream();

  OperandRange operands = forOp.getInitArgs();
  Block::BlockArgListType iterArgs = forOp.getRegionIterArgs();
  Operation::result_range results = forOp.getResults();

  if (!emitter.shouldDeclareVariablesAtTop()) {
    for (OpResult result : results) {
      if (failed(emitter.emitVariableDeclaration(result,
                                                 /*trailingSemicolon=*/true)))
        return failure();
    }
  }

  for (auto pair : llvm::zip(iterArgs, operands)) {
    if (failed(emitter.emitType(forOp.getLoc(), std::get<0>(pair).getType())))
      return failure();
    os << " " << emitter.getOrCreateName(std::get<0>(pair)) << " = ";
    os << emitter.getOrCreateName(std::get<1>(pair)) << ";";
    os << "\n";
  }

  os << "for (";
  if (failed(
          emitter.emitType(forOp.getLoc(), forOp.getInductionVar().getType())))
    return failure();
  os << " ";
  os << emitter.getOrCreateName(forOp.getInductionVar());
  os << " = ";
  os << emitter.getOrCreateName(forOp.getLowerBound());
  os << "; ";
  os << emitter.getOrCreateName(forOp.getInductionVar());
  os << " < ";
  os << emitter.getOrCreateName(forOp.getUpperBound());
  os << "; ";
  os << emitter.getOrCreateName(forOp.getInductionVar());
  os << " += ";
  os << emitter.getOrCreateName(forOp.getStep());
  os << ") {\n";
  os.indent();

  Region &forRegion = forOp.getRegion();
  auto regionOps = forRegion.getOps();

  // We skip the trailing yield op because this updates the result variables
  // of the for op in the generated code. Instead we update the iterArgs at
  // the end of a loop iteration and set the result variables after the for
  // loop.
  for (auto it = regionOps.begin(); std::next(it) != regionOps.end(); ++it) {
    if (failed(emitter.emitOperation(*it, /*trailingSemicolon=*/true)))
      return failure();
  }

  Operation *yieldOp = forRegion.getBlocks().front().getTerminator();
  // Copy yield operands into iterArgs at the end of a loop iteration.
  for (auto pair : llvm::zip(iterArgs, yieldOp->getOperands())) {
    BlockArgument iterArg = std::get<0>(pair);
    Value operand = std::get<1>(pair);
    os << emitter.getOrCreateName(iterArg) << " = "
       << emitter.getOrCreateName(operand) << ";\n";
  }

  os.unindent() << "}";

  // Copy iterArgs into results after the for loop.
  for (auto pair : llvm::zip(results, iterArgs)) {
    OpResult result = std::get<0>(pair);
    BlockArgument iterArg = std::get<1>(pair);
    os << "\n"
       << emitter.getOrCreateName(result) << " = "
       << emitter.getOrCreateName(iterArg) << ";";
  }

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::IfOp ifOp) {
  raw_indented_ostream &os = emitter.ostream();

  // Helper function to emit all ops except the last one, expected to be
  // emitc::yield.
  auto emitAllExceptLast = [&emitter](Region &region) {
    Region::OpIterator it = region.op_begin(), end = region.op_end();
    for (; std::next(it) != end; ++it) {
      if (failed(emitter.emitOperation(*it, /*trailingSemicolon=*/true)))
        return failure();
    }
    assert(isa<emitc::YieldOp>(*it) &&
           "Expected last operation in the region to be emitc::yield");
    return success();
  };

  os << "if (";
  if (failed(emitter.emitOperand(ifOp.getCondition())))
    return failure();
  os << ") {\n";
  os.indent();
  if (failed(emitAllExceptLast(ifOp.getThenRegion())))
    return failure();
  os.unindent() << "}";

  Region &elseRegion = ifOp.getElseRegion();
  if (!elseRegion.empty()) {
    os << " else {\n";
    os.indent();
    if (failed(emitAllExceptLast(elseRegion)))
      return failure();
    os.unindent() << "}";
  }

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, scf::YieldOp yieldOp) {
  raw_ostream &os = emitter.ostream();
  Operation &parentOp = *yieldOp.getOperation()->getParentOp();

  if (yieldOp.getNumOperands() != parentOp.getNumResults()) {
    return yieldOp.emitError("number of operands does not to match the number "
                             "of the parent op's results");
  }

  if (failed(interleaveWithError(
          llvm::zip(parentOp.getResults(), yieldOp.getOperands()),
          [&](auto pair) -> LogicalResult {
            auto result = std::get<0>(pair);
            auto operand = std::get<1>(pair);
            os << emitter.getOrCreateName(result) << " = ";

            if (!emitter.hasValueInScope(operand))
              return yieldOp.emitError("operand value not in scope");
            os << emitter.getOrCreateName(operand);
            return success();
          },
          [&]() { os << ";\n"; })))
    return failure();

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    func::ReturnOp returnOp) {
  raw_ostream &os = emitter.ostream();
  os << "return";
  switch (returnOp.getNumOperands()) {
  case 0:
    return success();
  case 1:
    os << " ";
    if (failed(emitter.emitOperand(returnOp.getOperand(0))))
      return failure();
    return success();
  default:
    os << " std::make_tuple(";
    if (failed(emitter.emitOperandsAndAttributes(*returnOp.getOperation())))
      return failure();
    os << ")";
    return success();
  }
}

// static LogicalResult printOperation(CppEmitter &emitter,
//                                     emitc::ReturnOp returnOp) {
//   raw_ostream &os = emitter.ostream();
//   os << "return";
//   if (returnOp.getNumOperands() == 0)
//     return success();

//   os << " ";
//   if (failed(emitter.emitOperand(returnOp.getOperand())))
//     return failure();
//   return success();
// }

static LogicalResult printOperation(CppEmitter &emitter, ModuleOp moduleOp) {
  CppEmitter::Scope scope(emitter);

  for (Operation &op : moduleOp) {
    if (failed(emitter.emitOperation(op, /*trailingSemicolon=*/false)))
      return failure();
  }
  return success();
}

// static LogicalResult printOperation(CppEmitter &emitter, FileOp file) {
//   if (!emitter.shouldEmitFile(file))
//     return success();

//   CppEmitter::Scope scope(emitter);

//   for (Operation &op : file) {
//     if (failed(emitter.emitOperation(op, /*trailingSemicolon=*/false)))
//       return failure();
//   }
//   return success();
// }

static LogicalResult printFunctionArgs(CppEmitter &emitter,
                                       Operation *functionOp,
                                       ArrayRef<Type> arguments) {
  raw_indented_ostream &os = emitter.ostream();

  return (
      interleaveCommaWithError(arguments, os, [&](Type arg) -> LogicalResult {
        return emitter.emitType(functionOp->getLoc(), arg);
      }));
}

static LogicalResult printFunctionArgs(CppEmitter &emitter,
                                       Operation *functionOp,
                                       Region::BlockArgListType arguments) {
  raw_indented_ostream &os = emitter.ostream();

  return (interleaveCommaWithError(
      arguments, os, [&](BlockArgument arg) -> LogicalResult {
        return emitter.emitVariableDeclaration(
            functionOp->getLoc(), arg.getType(), emitter.getOrCreateName(arg));
      }));
}

static LogicalResult printFunctionBody(CppEmitter &emitter,
                                       Operation *functionOp,
                                       Region::BlockListType &blocks) {
  raw_indented_ostream &os = emitter.ostream();
  os.indent();

  if (emitter.shouldDeclareVariablesAtTop()) {
    // Declare all variables that hold op results including those from nested
    // regions.
    WalkResult result =
        functionOp->walk<WalkOrder::PreOrder>([&](Operation *op) -> WalkResult {
          if (isa<emitc::ExpressionOp>(op->getParentOp()) ||
              (isa<emitc::ExpressionOp>(op) &&
               shouldBeInlined(cast<emitc::ExpressionOp>(op))))
            return WalkResult::skip();
          for (OpResult result : op->getResults()) {
            if (failed(emitter.emitVariableDeclaration(
                    result, /*trailingSemicolon=*/true))) {
              return WalkResult(
                  op->emitError("unable to declare result variable for op"));
            }
          }
          return WalkResult::advance();
        });
    if (result.wasInterrupted())
      return failure();
  }

  // Create label names for basic blocks.
  for (Block &block : blocks) {
    emitter.getOrCreateName(block);
  }

  // Declare variables for basic block arguments.
  for (Block &block : llvm::drop_begin(blocks)) {
    for (BlockArgument &arg : block.getArguments()) {
      if (emitter.hasValueInScope(arg))
        return functionOp->emitOpError(" block argument #")
               << arg.getArgNumber() << " is out of scope";
      if (isa<ArrayType, LValueType>(arg.getType()))
        return functionOp->emitOpError("cannot emit block argument #")
               << arg.getArgNumber() << " with type " << arg.getType();
      if (failed(
              emitter.emitType(block.getParentOp()->getLoc(), arg.getType()))) {
        return failure();
      }
      os << " " << emitter.getOrCreateName(arg) << ";\n";
    }
  }

  for (Block &block : blocks) {
    // Only print a label if the block has predecessors.
    if (!block.hasNoPredecessors()) {
      if (failed(emitter.emitLabel(block)))
        return failure();
    }
    for (Operation &op : block.getOperations()) {
      if (failed(emitter.emitOperation(op, /*trailingSemicolon=*/true)))
        return failure();
    }
  }

  os.unindent();

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    gpu::GPUModuleOp gpuModuleOp) {
  CppEmitter::Scope scope(emitter);

  // Print header for bishengCpp kernel function.
#ifdef GEN_BISHENGCPP_CODE
  raw_ostream &os = emitter.ostream();
  os << "#include <bisheng/bisheng.hpp>\n";
#endif

  for (Operation &op : gpuModuleOp) {
    if (failed(emitter.emitOperation(op, /*trailingSemicolon=*/false)))
      return failure();
  }
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    func::FuncOp functionOp) {
  // We need to declare variables at top if the function has multiple blocks.
  if (!emitter.shouldDeclareVariablesAtTop() &&
      functionOp.getBlocks().size() > 1) {
    return functionOp.emitOpError(
        "with multiple blocks needs variables declared at top");
  }

  // if (llvm::any_of(functionOp.getArgumentTypes(), llvm::IsaPred<LValueType>)) {
  //   return functionOp.emitOpError()
  //          << "cannot emit lvalue type as argument type";
  // }

  // if (llvm::any_of(functionOp.getResultTypes(), llvm::IsaPred<ArrayType>)) {
  //   return functionOp.emitOpError() << "cannot emit array type as result type";
  // }

  CppEmitter::Scope scope(emitter);
  raw_indented_ostream &os = emitter.ostream();
  if (failed(emitter.emitTypes(functionOp.getLoc(),
                               functionOp.getFunctionType().getResults())))
    return failure();
  os << " " << functionOp.getName();

  os << "(";
  Operation *operation = functionOp.getOperation();
  if (failed(printFunctionArgs(emitter, operation, functionOp.getArguments())))
    return failure();
  os << ") {\n";
  if (failed(printFunctionBody(emitter, operation, functionOp.getBlocks())))
    return failure();
  os << "}\n";

  return success();
}

// This is copied from the func::ReturnOp case, delete some codes. Because we
// think GPU and NPU's kernel function has no return value.
static LogicalResult printOperation(CppEmitter &emitter,
                                    gpu::ReturnOp returnOp) {
  raw_ostream &os = emitter.ostream();
  os << "return";
  if (returnOp.getNumOperands() > 0) {
    return emitError(returnOp.getLoc(),
                     "unexpected operands for gpu.return op!");
  }
  return success();
}

// Process gpu.module_end operation.
static LogicalResult printOperation(CppEmitter &emitter,
                                    gpu::ModuleEndOp moduleEndOp) {
  // do nothing.
  return success();
}

// Demangle function name.
static LogicalResult demangleName(gpu::GPUFuncOp functionOp,
                                  std::string &demangledName) {
  size_t size = 1;
  char *buf = static_cast<char *>(std::malloc(size));
  std::string mangledName = functionOp.getName().str();

  llvm::ItaniumPartialDemangler demangler;
  if (demangler.partialDemangle(mangledName.c_str())) {
    return emitError(functionOp.getLoc(),
                     "ICT_ERROR(): Failed to demangle function name");
  }
  char *result = demangler.getFunctionBaseName(buf, &size);
  if (result == nullptr) {
    return emitError(
        functionOp.getLoc(),
        "ICT_ERROR(): Failed to get result demangle function name");
  }
  demangledName = std::string(result);
  return success();
}

// This function is mainly copied from the func::FuncOp case. Change some codes
// to demangle function name, add memory address space for function arguments
// and so on.
static LogicalResult printOperation(CppEmitter &emitter,
                                    gpu::GPUFuncOp functionOp) {
  // We need to declare variables at top if the function has multiple blocks.
  if (!emitter.shouldDeclareVariablesAtTop() &&
      functionOp.getBlocks().size() > 1) {
    return functionOp.emitOpError(
        "with multiple blocks needs variables declared at top");
  }

  CppEmitter::Scope scope(emitter);
  raw_indented_ostream &os = emitter.ostream();
  // Print function signature.
#ifdef GEN_BISHENGCPP_CODE
  os << "extern \"C\" __global__ __aivector__ ";
#else
  os << "extern \"C\" __global__ [aicore] ";
#endif
  // Function return type.
  if (failed(emitter.emitTypes(functionOp.getLoc(),
                               functionOp.getFunctionType().getResults())))
    return failure();
  // Function name.
  std::string demangledName;
  if(failed(demangleName(functionOp, demangledName))) {
    return failure();
  }
  os << " " << demangledName;

  os << "(";
  if (failed(interleaveCommaWithError(
          functionOp.getArguments(), os,
          [&](BlockArgument arg) -> LogicalResult {
            auto argType = arg.getType();
            if(auto memRefType = argType.dyn_cast<MemRefType>()) {
              argType = MemRefType::get(
                  memRefType.getShape(), memRefType.getElementType(),
                  {}, /* memspace */ 1);
            }
            if (failed(emitter.emitType(functionOp.getLoc(), argType)))
              return failure();
            os << " " << emitter.getOrCreateName(arg);
            return success();
          })))
    return failure();
  os << ") {\n";
  os.indent();
  // Print `using namespace bisheng` for bishengCpp kernel function.
#ifdef GEN_BISHENGCPP_CODE
  os << "using namespace bisheng;\n";
#endif
  if (emitter.shouldDeclareVariablesAtTop()) {
    // Declare all variables that hold op results including those from nested
    // regions.
    WalkResult result =
        functionOp.walk<WalkOrder::PreOrder>([&](Operation *op) -> WalkResult {
          for (OpResult result : op->getResults()) {
            if (failed(emitter.emitVariableDeclaration(
                    result, /*trailingSemicolon=*/true))) {
              return WalkResult(
                  op->emitError("unable to declare result variable for op"));
            }
          }
          return WalkResult::advance();
        });
    if (result.wasInterrupted())
      return failure();
  }

  Region::BlockListType &blocks = functionOp.getBlocks();
  // Create label names for basic blocks.
  for (Block &block : blocks) {
    emitter.getOrCreateName(block);
  }

  // Declare variables for basic block arguments.
  for (Block &block : llvm::drop_begin(blocks)) {
    for (BlockArgument &arg : block.getArguments()) {
      if (emitter.hasValueInScope(arg))
        return functionOp.emitOpError(" block argument #")
               << arg.getArgNumber() << " is out of scope";
      if (failed(
              emitter.emitType(block.getParentOp()->getLoc(), arg.getType()))) {
        return failure();
      }
      os << " " << emitter.getOrCreateName(arg) << ";\n";
    }
  }

  for (Block &block : blocks) {
    // Only print a label if the block has predecessors.
    if (!block.hasNoPredecessors()) {
      if (failed(emitter.emitLabel(block)))
        return failure();
    }
    for (Operation &op : block.getOperations()) {
      // When generating code for an emitc.if or cf.cond_br op no semicolon
      // needs to be printed after the closing brace.
      // When generating code for an scf.for op, printing a trailing semicolon
      // is handled within the printOperation function.
      // TODO: 这里需要加emitc::ForOp吗？似乎应该？
      bool trailingSemicolon =
          !isa<cf::CondBranchOp, emitc::LiteralOp, emitc::IfOp, scf::ForOp, emitc::ForOp>(op);

      if (failed(emitter.emitOperation(
              op, /*trailingSemicolon=*/trailingSemicolon)))
        return failure();
    }
  }
  os.unindent() << "}\n";
  return success();
}

// static LogicalResult printOperation(CppEmitter &emitter,
//                                     emitc::FuncOp functionOp) {
//   // We need to declare variables at top if the function has multiple blocks.
//   if (!emitter.shouldDeclareVariablesAtTop() &&
//       functionOp.getBlocks().size() > 1) {
//     return functionOp.emitOpError(
//         "with multiple blocks needs variables declared at top");
//   }

//   CppEmitter::Scope scope(emitter);
//   raw_indented_ostream &os = emitter.ostream();
//   if (functionOp.getSpecifiers()) {
//     for (Attribute specifier : functionOp.getSpecifiersAttr()) {
//       os << cast<StringAttr>(specifier).str() << " ";
//     }
//   }

//   if (failed(emitter.emitTypes(functionOp.getLoc(),
//                                functionOp.getFunctionType().getResults())))
//     return failure();
//   os << " " << functionOp.getName();

//   os << "(";
//   Operation *operation = functionOp.getOperation();
//   if (functionOp.isExternal()) {
//     if (failed(printFunctionArgs(emitter, operation,
//                                  functionOp.getArgumentTypes())))
//       return failure();
//     os << ");";
//     return success();
//   }
//   if (failed(printFunctionArgs(emitter, operation, functionOp.getArguments())))
//     return failure();
//   os << ") {\n";
//   if (failed(printFunctionBody(emitter, operation, functionOp.getBlocks())))
//     return failure();
//   os << "}\n";

//   return success();
// }

// static LogicalResult printOperation(CppEmitter &emitter,
//                                     DeclareFuncOp declareFuncOp) {
//   CppEmitter::Scope scope(emitter);
//   raw_indented_ostream &os = emitter.ostream();

//   auto functionOp = SymbolTable::lookupNearestSymbolFrom<emitc::FuncOp>(
//       declareFuncOp, declareFuncOp.getSymNameAttr());

//   if (!functionOp)
//     return failure();

//   if (functionOp.getSpecifiers()) {
//     for (Attribute specifier : functionOp.getSpecifiersAttr()) {
//       os << cast<StringAttr>(specifier).str() << " ";
//     }
//   }

//   if (failed(emitter.emitTypes(functionOp.getLoc(),
//                                functionOp.getFunctionType().getResults())))
//     return failure();
//   os << " " << functionOp.getName();

//   os << "(";
//   Operation *operation = functionOp.getOperation();
//   if (failed(printFunctionArgs(emitter, operation, functionOp.getArguments())))
//     return failure();
//   os << ");";

//   return success();
// }

CppEmitter::CppEmitter(raw_ostream &os, bool declareVariablesAtTop/*,
                       StringRef fileId*/)
    : os(os), declareVariablesAtTop(declareVariablesAtTop)/*,
      fileId(fileId.str())*/ {
  valueInScopeCount.push(0);
  labelInScopeCount.push(0);
}

std::string CppEmitter::getSubscriptName(emitc::SubscriptOp op) {
  std::string out;
  llvm::raw_string_ostream ss(out);
  ss << getOrCreateName(op.getValue());
  for (auto index : op.getIndices()) {
    ss << "[" << getOrCreateName(index) << "]";
  }
  return out;
}

std::string CppEmitter::createMemberAccess(emitc::MemberOp op) {
  std::string out;
  llvm::raw_string_ostream ss(out);
  ss << getOrCreateName(op.getOperand());
  ss << "." << op.getMember();
  return out;
}

std::string CppEmitter::createMemberAccess(emitc::MemberOfPtrOp op) {
  std::string out;
  llvm::raw_string_ostream ss(out);
  ss << getOrCreateName(op.getOperand());
  ss << "->" << op.getMember();
  return out;
}

void CppEmitter::cacheDeferredOpResult(Value value, StringRef str) {
  if (!valueMapper.count(value))
    valueMapper.insert(value, str.str());
}

/// Return the existing or a new name for a Value.
StringRef CppEmitter::getOrCreateName(Value val) {
  if (!valueMapper.count(val)) {
    assert(!hasDeferredEmission(val.getDefiningOp()) &&
           "cacheDeferredOpResult should have been called on this value, "
           "update the emitOperation function.");
    valueMapper.insert(val, formatv("v{0}", ++valueInScopeCount.top()));
  }
  return *valueMapper.begin(val);
}

/// Return the existing or a new label for a Block.
StringRef CppEmitter::getOrCreateName(Block &block) {
  if (!blockMapper.count(&block))
    blockMapper.insert(&block, formatv("label{0}", ++labelInScopeCount.top()));
  return *blockMapper.begin(&block);
}

StringRef CppEmitter::getOrCreateNameAlias(Value val) {
  auto Defop = val.getDefiningOp();
  if (Defop->hasAttr("ub-allocation-index")) {
    auto AllocationIndex =
        Defop->getAttrOfType<IntegerAttr>("ub-allocation-index").getInt();
    if (AllocationMap.count(AllocationIndex)) {
      return getOrCreateName(AllocationMap[AllocationIndex]);
    }
  }
  return getOrCreateName(val);
}

bool CppEmitter::shouldMapToUnsigned(IntegerType::SignednessSemantics val) {
  switch (val) {
  case IntegerType::Signless:
    return false;
  case IntegerType::Signed:
    return false;
  case IntegerType::Unsigned:
    return true;
  }
  llvm_unreachable("Unexpected IntegerType::SignednessSemantics");
}

bool CppEmitter::hasValueInScope(Value val) { return valueMapper.count(val); }

bool CppEmitter::hasBlockLabel(Block &block) {
  return blockMapper.count(&block);
}

LogicalResult CppEmitter::emitAttribute(Location loc, Attribute attr) {
  auto printInt = [&](const APInt &val, bool isUnsigned) {
    if (val.getBitWidth() == 1) {
      if (val.getBoolValue())
        os << "true";
      else
        os << "false";
    } else {
      SmallString<128> strValue;
      val.toString(strValue, 10, !isUnsigned, false);
      os << strValue;
    }
  };

  auto printFloat = [&](const APFloat &val) {
    if (val.isFinite()) {
      SmallString<128> strValue;
      // Use default values of toString except don't truncate zeros.
      val.toString(strValue, 0, 0, false);
      os << strValue;
      switch (llvm::APFloatBase::SemanticsToEnum(val.getSemantics())) {
      case llvm::APFloatBase::S_IEEEhalf:
        os << "f16";
        break;
      case llvm::APFloatBase::S_BFloat:
        os << "bf16";
        break;
      case llvm::APFloatBase::S_IEEEsingle:
        os << "f";
        break;
      case llvm::APFloatBase::S_IEEEdouble:
        break;
      default:
        llvm_unreachable("unsupported floating point type");
      };
    } else if (val.isNaN()) {
      os << "NAN";
    } else if (val.isInfinity()) {
      if (val.isNegative())
        os << "-";
      os << "INFINITY";
    }
  };

  // Print floating point attributes.
  if (auto fAttr = dyn_cast<FloatAttr>(attr)) {
    if (!isa<Float16Type, BFloat16Type, Float32Type, Float64Type>(
            fAttr.getType())) {
      return emitError(
          loc, "expected floating point attribute to be f16, bf16, f32 or f64");
    }
    printFloat(fAttr.getValue());
    return success();
  }
  if (auto dense = dyn_cast<DenseFPElementsAttr>(attr)) {
    if (!isa<Float16Type, BFloat16Type, Float32Type, Float64Type>(
            dense.getElementType())) {
      return emitError(
          loc, "expected floating point attribute to be f16, bf16, f32 or f64");
    }
    os << '{';
    interleaveComma(dense, os, [&](const APFloat &val) { printFloat(val); });
    os << '}';
    return success();
  }

  // Print integer attributes.
  if (auto iAttr = dyn_cast<IntegerAttr>(attr)) {
    if (auto iType = dyn_cast<IntegerType>(iAttr.getType())) {
      printInt(iAttr.getValue(), shouldMapToUnsigned(iType.getSignedness()));
      return success();
    }
    if (auto iType = dyn_cast<IndexType>(iAttr.getType())) {
      printInt(iAttr.getValue(), false);
      return success();
    }
  }
  if (auto dense = dyn_cast<DenseIntElementsAttr>(attr)) {
    if (auto iType = dyn_cast<IntegerType>(
            cast<TensorType>(dense.getType()).getElementType())) {
      os << '{';
      interleaveComma(dense, os, [&](const APInt &val) {
        printInt(val, shouldMapToUnsigned(iType.getSignedness()));
      });
      os << '}';
      return success();
    }
    if (auto iType = dyn_cast<IndexType>(
            cast<TensorType>(dense.getType()).getElementType())) {
      os << '{';
      interleaveComma(dense, os,
                      [&](const APInt &val) { printInt(val, false); });
      os << '}';
      return success();
    }
  }

  // Print opaque attributes.
  if (auto oAttr = dyn_cast<emitc::OpaqueAttr>(attr)) {
    os << oAttr.getValue();
    return success();
  }

  // Print symbolic reference attributes.
  if (auto sAttr = dyn_cast<SymbolRefAttr>(attr)) {
    if (sAttr.getNestedReferences().size() > 1)
      return emitError(loc, "attribute has more than 1 nested reference");
    os << sAttr.getRootReference().getValue();
    return success();
  }

  // Print type attributes.
  if (auto type = dyn_cast<TypeAttr>(attr))
    return emitType(loc, type.getValue());

  return emitError(loc, "cannot emit attribute: ") << attr;
}

LogicalResult CppEmitter::emitExpression(ExpressionOp expressionOp) {
  assert(emittedExpressionPrecedence.empty() &&
         "Expected precedence stack to be empty");
  Operation *rootOp = expressionOp.getRootOp();

  emittedExpression = expressionOp;
  FailureOr<int> precedence = getOperatorPrecedence(rootOp);
  if (failed(precedence))
    return failure();
  pushExpressionPrecedence(precedence.value());

  if (failed(emitOperation(*rootOp, /*trailingSemicolon=*/false)))
    return failure();

  popExpressionPrecedence();
  assert(emittedExpressionPrecedence.empty() &&
         "Expected precedence stack to be empty");
  emittedExpression = nullptr;

  return success();
}

LogicalResult CppEmitter::emitOperand(Value value) {
  if (isPartOfCurrentExpression(value)) {
    Operation *def = value.getDefiningOp();
    assert(def && "Expected operand to be defined by an operation");
    FailureOr<int> precedence = getOperatorPrecedence(def);
    if (failed(precedence))
      return failure();

    // Sub-expressions with equal or lower precedence need to be parenthesized,
    // as they might be evaluated in the wrong order depending on the shape of
    // the expression tree.
    bool encloseInParenthesis = precedence.value() <= getExpressionPrecedence();
    if (encloseInParenthesis)
      os << "(";
    pushExpressionPrecedence(precedence.value());

    if (failed(emitOperation(*def, /*trailingSemicolon=*/false)))
      return failure();

    if (encloseInParenthesis)
      os << ")";

    popExpressionPrecedence();
    return success();
  }

  auto expressionOp = dyn_cast_if_present<ExpressionOp>(value.getDefiningOp());
  if (expressionOp && shouldBeInlined(expressionOp))
    return emitExpression(expressionOp);

  os << getOrCreateName(value);
  return success();
}

LogicalResult CppEmitter::emitOperands(Operation &op) {
  return interleaveCommaWithError(op.getOperands(), os, [&](Value operand) {
    // If an expression is being emitted, push lowest precedence as these
    // operands are either wrapped by parenthesis.
    if (getEmittedExpression())
      pushExpressionPrecedence(lowestPrecedence());
    if (failed(emitOperand(operand)))
      return failure();
    if (getEmittedExpression())
      popExpressionPrecedence();
    return success();
  });
}

LogicalResult CppEmitter::emitAddLikeOperands(Operation &op) {
  auto emitOperandName = [&](Value result) -> LogicalResult {
    if (!hasValueInScope(result))
      return op.emitOpError() << "operand value not in scope";
    os << getOrCreateName(result);
    return success();
  };
  return interleaveAddWithError(op.getOperands(), os, emitOperandName);
}

LogicalResult
CppEmitter::emitOperandsAndAttributes(Operation &op,
                                      ArrayRef<StringRef> exclude) {
  if (failed(emitOperands(op)))
    return failure();
  // Insert comma in between operands and non-filtered attributes if needed.
  if (op.getNumOperands() > 0) {
    for (NamedAttribute attr : op.getAttrs()) {
      if (!llvm::is_contained(exclude, attr.getName().strref())) {
        os << ", ";
        break;
      }
    }
  }
  // Emit attributes.
  auto emitNamedAttribute = [&](NamedAttribute attr) -> LogicalResult {
    if (llvm::is_contained(exclude, attr.getName().strref()))
      return success();
    os << "/* " << attr.getName().getValue() << " */";
    if (failed(emitAttribute(op.getLoc(), attr.getValue())))
      return failure();
    return success();
  };
  return interleaveCommaWithError(op.getAttrs(), os, emitNamedAttribute);
}

LogicalResult CppEmitter::emitVariableAssignment(OpResult result) {
  if (!hasValueInScope(result)) {
    return result.getDefiningOp()->emitOpError(
        "result variable for the operation has not been declared");
  }
  os << getOrCreateName(result) << " = ";
  return success();
}

LogicalResult CppEmitter::emitVariableDeclaration(OpResult result,
                                                  bool trailingSemicolon) {
  if (hasDeferredEmission(result.getDefiningOp()))
    return success();
  if (hasValueInScope(result)) {
    return result.getDefiningOp()->emitError(
        "result variable for the operation already declared");
  }
  if (failed(emitVariableDeclaration(result.getOwner()->getLoc(),
                                     result.getType(),
                                     getOrCreateName(result))))
    return failure();
  if (trailingSemicolon)
    os << ";\n";
  return success();
}

LogicalResult CppEmitter::emitGlobalVariable(GlobalOp op) {
  if (op.getExternSpecifier())
    os << "extern ";
  else if (op.getStaticSpecifier())
    os << "static ";
  if (op.getConstSpecifier())
    os << "const ";

  if (failed(emitVariableDeclaration(op->getLoc(), op.getType(),
                                     op.getSymName()))) {
    return failure();
  }

  std::optional<Attribute> initialValue = op.getInitialValue();
  if (initialValue) {
    os << " = ";
    if (failed(emitAttribute(op->getLoc(), *initialValue)))
      return failure();
  }

  os << ";";
  return success();
}

LogicalResult CppEmitter::emitAssignPrefix(Operation &op) {
  // If op is being emitted as part of an expression, bail out.
  if (getEmittedExpression())
    return success();

  switch (op.getNumResults()) {
  case 0:
    break;
  case 1: {
    OpResult result = op.getResult(0);
    if (shouldDeclareVariablesAtTop()) {
      if (failed(emitVariableAssignment(result)))
        return failure();
    } else {
      if (failed(emitVariableDeclaration(result, /*trailingSemicolon=*/false)))
        return failure();
      os << " = ";
    }
    break;
  }
  default:
    if (!shouldDeclareVariablesAtTop()) {
      for (OpResult result : op.getResults()) {
        if (failed(emitVariableDeclaration(result, /*trailingSemicolon=*/true)))
          return failure();
      }
    }
    os << "std::tie(";
    interleaveComma(op.getResults(), os,
                    [&](Value result) { os << getOrCreateName(result); });
    os << ") = ";
  }
  return success();
}

LogicalResult CppEmitter::emitLabel(Block &block) {
  if (!hasBlockLabel(block))
    return block.getParentOp()->emitError("label for block not found");
  // FIXME: Add feature in `raw_indented_ostream` to ignore indent for block
  // label instead of using `getOStream`.
  os.getOStream() << getOrCreateName(block) << ":\n";
  return success();
}

LogicalResult CppEmitter::emitOperation(Operation &op, bool trailingSemicolon) {
  LogicalResult status =
      llvm::TypeSwitch<Operation *, LogicalResult>(&op)
          // Builtin ops.
          .Case<ModuleOp>([&](auto op) { return printOperation(*this, op); })
          // CF ops.
          .Case<cf::BranchOp, cf::CondBranchOp>(
              [&](auto op) { return printOperation(*this, op); })
          // EmitC ops.
          .Case<emitc::AddOp, emitc::ApplyOp, emitc::AssignOp,
                emitc::BitwiseAndOp, emitc::BitwiseLeftShiftOp,
                emitc::BitwiseNotOp, emitc::BitwiseOrOp,
                emitc::BitwiseRightShiftOp, emitc::BitwiseXorOp, /*emitc::CallOp,*/
                emitc::CallOpaqueOp, emitc::CastOp, emitc::CmpOp,
                emitc::ConditionalOp, emitc::ConstantOp, /*emitc::DeclareFuncOp,*/
                emitc::DivOp, emitc::ExpressionOp, /*emitc::FileOp,*/ emitc::ForOp,
                /*emitc::FuncOp,*/ emitc::GlobalOp, emitc::IfOp, emitc::IncludeOp,
                emitc::LoadOp, emitc::LogicalAndOp, emitc::LogicalNotOp,
                emitc::LogicalOrOp, emitc::MulOp, emitc::RemOp, /*emitc::ReturnOp,*/
                emitc::SubOp, emitc::SwitchOp, emitc::UnaryMinusOp,
                emitc::UnaryPlusOp, emitc::VariableOp, emitc::VerbatimOp>(

              [&](auto op) { return printOperation(*this, op); })
          // Func ops.
          .Case<func::CallOp, func::FuncOp, func::ReturnOp>(
              [&](auto op) { return printOperation(*this, op); })
          // SCF ops.
          .Case<scf::ForOp, scf::YieldOp>(
              [&](auto op) { return printOperation(*this, op); })
          .Case<emitc::GetGlobalOp>([&](auto op) {
            cacheDeferredOpResult(op.getResult(), op.getName());
            return success();
          })
          .Case<emitc::LiteralOp>([&](auto op) {
            cacheDeferredOpResult(op.getResult(), op.getValue());
            return success();
          })
          // GPU ops.
          .Case<gpu::GPUModuleOp, gpu::GPUFuncOp, gpu::ReturnOp,
                gpu::ModuleEndOp>(
              [&](auto op) { return printOperation(*this, op); })
          // Builtin.xx ops.
          .Case<UnrealizedConversionCastOp>([&](auto op) {
            return printBuiltinUnrealizedConversionOp(*this, op);
          })
          // MemRef ops.
          .Case<memref::LoadOp>([&](auto op) {
            return printMemRefOp(*this, op);
          })
          // LLVM ops.
          .Case<LLVM::GEPOp>([&](auto op) { return printLLVMGEPOp(*this, op); })
          // NPU ops.
          .Case<npu::MovOutToUBOp, npu::MovUBToOutOp, 
                npu::VAddF32Op, npu::VAddI32Op, npu::VMulF32Op,
                npu::VCmpI32Op, npu::VSelOp, npu::AtomicAddF32Op,
                npu::BroadCastI32Op, npu::MOVEVF32Op, npu::AssignUBI32Op, 
                npu::LoadUBI32Op, npu::StoreUBI32Op, 
                npu::AllocaUBVectorOp, npu::AllocaAddr,
                npu::BlockIdOp>(
              [&](auto op) { return printNPUOp(*this, op); })
          .Case<emitc::MemberOp>([&](auto op) {
            cacheDeferredOpResult(op.getResult(), createMemberAccess(op));
            return success();
          })
          .Case<emitc::MemberOfPtrOp>([&](auto op) {
            cacheDeferredOpResult(op.getResult(), createMemberAccess(op));
            return success();
          })
          .Case<emitc::SubscriptOp>([&](auto op) {
            cacheDeferredOpResult(op.getResult(), getSubscriptName(op));
            return success();
          })
          .Default([&](Operation *) {
            return op.emitOpError("unable to find printer for op");
          });

  if (failed(status))
    return failure();

  if (hasDeferredEmission(&op))
    return success();

  if (getEmittedExpression() ||
      (isa<emitc::ExpressionOp>(op) &&
       shouldBeInlined(cast<emitc::ExpressionOp>(op))))
    return success();

  // Never emit a semicolon for some operations, especially if endening with
  // `}`.
  trailingSemicolon &=
      !isa<cf::CondBranchOp, /*emitc::DeclareFuncOp,*/ /*emitc::FileOp,*/ emitc::ForOp,
           emitc::IfOp, emitc::IncludeOp, emitc::SwitchOp, emitc::VerbatimOp>(
          op);

  os << (trailingSemicolon ? ";\n" : "\n");

  return success();
}

LogicalResult CppEmitter::emitVariableDeclaration(Location loc, Type type,
                                                  StringRef name) {
  if (auto arrType = dyn_cast<emitc::ArrayType>(type)) {
    if (failed(emitType(loc, arrType.getElementType())))
      return failure();
    os << " " << name;
    for (auto dim : arrType.getShape()) {
      os << "[" << dim << "]";
    }
    return success();
  }
  if (failed(emitType(loc, type)))
    return failure();
  os << " " << name;
  return success();
}

LogicalResult CppEmitter::emitType(Location loc, Type type) {
  if (auto iType = dyn_cast<IntegerType>(type)) {
    switch (iType.getWidth()) {
    case 1:
      return (os << "bool"), success();
    case 8:
    case 16:
    case 32:
    case 64:
      if (shouldMapToUnsigned(iType.getSignedness()))
        return (os << "uint" << iType.getWidth() << "_t"), success();
      else
        return (os << "int" << iType.getWidth() << "_t"), success();
    default:
      return emitError(loc, "cannot emit integer type ") << type;
    }
  }
  if (auto fType = dyn_cast<FloatType>(type)) {
    switch (fType.getWidth()) {
    case 16: {
      if (llvm::isa<Float16Type>(type))
        return (os << "_Float16"), success();
      else if (llvm::isa<BFloat16Type>(type))
        return (os << "__bf16"), success();
      else
        return emitError(loc, "cannot emit float type ") << type;
    }
    case 32:
      return (os << "float"), success();
    case 64:
      return (os << "double"), success();
    default:
      return emitError(loc, "cannot emit float type ") << type;
    }
  }
  if (auto iType = dyn_cast<IndexType>(type))
    // TODO:: 把index 翻译为size_t，正确吗？index是signless的，size_t是unsigned的
    return (os << "size_t"), success();
  if (auto sType = dyn_cast<emitc::SizeTType>(type))
    return (os << "size_t"), success();
  if (auto sType = dyn_cast<emitc::SignedSizeTType>(type))
    return (os << "ssize_t"), success();
  if (auto pType = dyn_cast<emitc::PtrDiffTType>(type))
    return (os << "ptrdiff_t"), success();
  if (auto tType = dyn_cast<TensorType>(type)) {
    if (!tType.hasRank())
      return emitError(loc, "cannot emit unranked tensor type");
    if (!tType.hasStaticShape())
      return emitError(loc, "cannot emit tensor type with non static shape");
    os << "Tensor<";
    if (isa<ArrayType>(tType.getElementType()))
      return emitError(loc, "cannot emit tensor of array type ") << type;
    if (failed(emitType(loc, tType.getElementType())))
      return failure();
    auto shape = tType.getShape();
    for (auto dimSize : shape) {
      os << ", ";
      os << dimSize;
    }
    os << ">";
    return success();
  }
  if (auto tType = dyn_cast<TupleType>(type))
    return emitTupleType(loc, tType.getTypes());
  if (auto oType = dyn_cast<emitc::OpaqueType>(type)) {
    os << oType.getValue();
    return success();
  }
  if (auto aType = dyn_cast<emitc::ArrayType>(type)) {
    if (failed(emitType(loc, aType.getElementType())))
      return failure();
    for (auto dim : aType.getShape())
      os << "[" << dim << "]";
    return success();
  }
  if (auto lType = dyn_cast<emitc::LValueType>(type))
    return emitType(loc, lType.getValueType());
  if (auto pType = dyn_cast<emitc::PointerType>(type)) {
    if (isa<ArrayType>(pType.getPointee()))
      return emitError(loc, "cannot emit pointer to array type ") << type;
    if (failed(emitType(loc, pType.getPointee())))
      return failure();
    os << "*";
    return success();
  }
  if (auto memrefType = dyn_cast<MemRefType>(type)) {
    // Emit memory space.
    // TODO: MemRefType space == 1是啥情况？在哪里设置的？我没啥印象了，emmm
    if (memrefType.getMemorySpaceAsInt() == 1 || memrefType.getMemorySpaceAsInt() == 0) {
#ifdef GEN_BISHENGCPP_CODE
      os << "__global ";
#else
      os << "__gm__ ";
#endif
    } else if (memrefType.getMemorySpaceAsInt() == 6) {
#ifdef GEN_BISHENGCPP_CODE
      os << "__local ";
#else
      os << "__ubuf__ ";
#endif
    } else {
      return emitError(loc, "ICT_ERROR(): cannot emit MemRef memory space: ")
             << memrefType.getMemorySpaceAsInt();
    }
    // Emit element type.
    if (auto fType = dyn_cast<FloatType>(memrefType.getElementType())) {
      if (fType.getWidth() == 32)
        os << "float";
      else
        return emitError(loc, "ICT_ERROR(): cannot emit MemRef float type "
                              "which width != 32: ")
               << fType;
    } else {
      return emitError(loc, "ICT_ERROR(): cannot emit MemRef element type: ")
             << memrefType;
    }
    os << "*";
    return success();
  }
  // Emit CCE code for llvm pointer type, example:
  //  __gm__ float* or __ubuf__ float*
  if (auto llvmPtrType = dyn_cast<LLVM::LLVMPointerType>(type)) {
    Type elementType;
    if (llvmPtrType.getAddressSpace() == 1) {
#ifdef GEN_BISHENGCPP_CODE
      os << "__global ";
#else
      os << "__gm__ ";
#endif
      if (llvmPtrType.isOpaque())
        elementType = IntegerType::get(llvmPtrType.getContext(), 8,
                                       IntegerType::Unsigned);
      else
        elementType = llvmPtrType.getElementType();
    } else if (llvmPtrType.getAddressSpace() == 6) {
#ifdef GEN_BISHENGCPP_CODE
      os << "__local ";
#else
      os << "__ubuf__ ";
#endif
      if (llvmPtrType.isOpaque())
        elementType = Float32Type::get(llvmPtrType.getContext());
      else
        elementType = llvmPtrType.getElementType();
    } else
      return emitError(loc, "ICT_ERROR(): cannot emit address space: ")
             << llvmPtrType.getAddressSpace();
    if (failed(emitType(loc, elementType)))
      return failure();
    os << "*";
    return success();
  }
  // process vector<Nxf32> type
  if (auto vecType = dyn_cast<VectorType>(type)) {
    auto elemType = vecType.getElementType();  // vector's element type, such as float
    os << "__ubuf__ ";    // vector variables must be in ubuf
    if(failed(emitType(loc, elemType)))   // such as os << "float";
      return failure();
    os << "*";
    return success();
  }
  return emitError(loc, "cannot emit type ") << type;
}

LogicalResult CppEmitter::emitTypes(Location loc, ArrayRef<Type> types) {
  switch (types.size()) {
  case 0:
    os << "void";
    return success();
  case 1:
    return emitType(loc, types.front());
  default:
    return emitTupleType(loc, types);
  }
}

LogicalResult CppEmitter::emitTupleType(Location loc, ArrayRef<Type> types) {
  // if (llvm::any_of(types, llvm::IsaPred<ArrayType>)) {
  //   return emitError(loc, "cannot emit tuple of array type");
  // }
  os << "std::tuple<";
  if (failed(interleaveCommaWithError(
          types, os, [&](Type type) { return emitType(loc, type); })))
    return failure();
  os << ">";
  return success();
}

LogicalResult emitc::translateToCpp(Operation *op, raw_ostream &os,
                                    bool declareVariablesAtTop/*,
                                    StringRef fileId*/) {
  CppEmitter emitter(os, declareVariablesAtTop/*, fileId*/);
  return emitter.emitOperation(*op, /*trailingSemicolon=*/false);
}
