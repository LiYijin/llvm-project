//===- TranslateToCpp.cpp - Translating to C++ calls ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Dialect/EmitC/IR/EmitC.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMTypes.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Support/IndentedOstream.h"
#include "mlir/Target/Cpp/CppEmitter.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FormatVariadic.h"
#include "mlir/Dialect/NPU/IR/NPUDialect.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/ADT/StringSwitch.h"
#include <utility>

#define DEBUG_TYPE "translate-to-cpp"

using namespace mlir;
using namespace mlir::memref;
using namespace mlir::arith;
using namespace mlir::emitc;
using llvm::formatv;

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

namespace {
/// Emitter that uses dialect specific emitters to emit C++ code.
struct CppEmitter {
  explicit CppEmitter(raw_ostream &os, bool declareVariablesAtTop);

  /// Emits attribute or returns failure.
  LogicalResult emitAttribute(Location loc, Attribute attr);

  /// Emits operation 'op' with/without training semicolon or returns failure.
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

  /// Emits the variable declaration and assignment prefix for 'op'.
  /// - emits separate variable followed by std::tie for multi-valued operation;
  /// - emits single type followed by variable for single result;
  /// - emits nothing if no value produced by op;
  /// Emits final '=' operator where a type is produced. Returns failure if
  /// any result type could not be converted.
  LogicalResult emitAssignPrefix(Operation &op);

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

  /// Return the existing or a new name for a Value.
  StringRef getOrCreateName(Value val);

  /// Return the existing or a new label of a Block.
  StringRef getOrCreateName(Block &block);

  /// Create a new name for a Value.
  void createValueName(Value val, StringRef name);

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

private:
  using ValueMapper = llvm::ScopedHashTable<Value, std::string>;
  using BlockMapper = llvm::ScopedHashTable<Block *, std::string>;

  /// Output stream to emit to.
  raw_indented_ostream os;

  /// Boolean to enforce that all variables for op results and block
  /// arguments are declared at the beginning of the function. This also
  /// includes results from ops located in nested regions.
  bool declareVariablesAtTop;

  /// Map from value to name of C++ variable that contain the name.
  ValueMapper valueMapper;

  /// Map from block to name of C++ label.
  BlockMapper blockMapper;

  /// The number of values in the current scope. This is used to declare the
  /// names of values in a scope.
  std::stack<int64_t> valueInScopeCount;
  std::stack<int64_t> labelInScopeCount;
};
} // namespace

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

  if (auto vecType = dyn_cast<VectorType>(result.getType())) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();

    auto denseAttr = dyn_cast<DenseFPElementsAttr>(value);
    assert(denseAttr && denseAttr.isSplat());
    
    auto &os = emitter.ostream();
    os << "__bang_write_value("
       << emitter.getOrCreateName(result) << ", "
       << vecType.getNumElements() << ", (";

    (void)emitter.emitType(operation->getLoc(), vecType.getElementType());

    os << ")" << denseAttr.getValues<APFloat>()[0].convertToFloat() << ")";
    return success();
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
                                    arith::ConstantOp constantOp) {
  Operation *operation = constantOp.getOperation();
  Attribute value = constantOp.getValue();

  return printConstantOp(emitter, operation, value);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    func::ConstantOp constantOp) {
  Operation *operation = constantOp.getOperation();
  Attribute value = constantOp.getValueAttr();

  return printConstantOp(emitter, operation, value);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    LLVM::ConstantOp constantOp) {
                                      Operation *operation = constantOp.getOperation();
                                      Attribute value = constantOp.getValueAttr();
                                    
                                      return printConstantOp(emitter, operation, value);
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    emitc::AssignOp assignOp) {
  auto variableOp = cast<emitc::VariableOp>(assignOp.getVar().getDefiningOp());
  OpResult result = variableOp->getResult(0);

  if (auto vecTy = dyn_cast<VectorType>(result.getType())) {
    // Since the vector type will be lowered as an array on nram which is not assignable,
    // so we should overload the emitter using a nram to nram memcpy instead.
    if (!emitter.hasValueInScope(result))
      return failure();
    
    emitter.ostream() << "__memcpy(" << emitter.getOrCreateName(result)
                      << ", " << emitter.getOrCreateName(assignOp.getValue())
                      << ", " << vecTy.getNumElements() * vecTy.getElementTypeBitWidth() / 8 << ", NRAM2NRAM)";
  } else {
    if (failed(emitter.emitVariableAssignment(result)))
      return failure();

    emitter.ostream() << emitter.getOrCreateName(assignOp.getValue());
  }
  return success();
}

// Process the builtin.unrealized_conversion_cast operation:
//   %0 = "builtin.unrealized_conversion_cast"(%1) : (index) -> i32
//   ->
//   %0 = %1; (%1 has been converted to i32)
// static LogicalResult
// printBuiltinUnrealizedConversionOp(CppEmitter &emitter,
//                                    UnrealizedConversionCastOp operation) {
//   if (failed(emitter.emitAssignPrefix(*operation)))
//     return failure();
//   raw_ostream &os = emitter.ostream();
//   os << "("; 
//   emitter.emitType(operation.getLoc(), operation->getResult(0).getType()); // require add type cast same to the operation's type
//   os << ")"; 
//   if (failed(emitter.emitOperands(*operation)))
//     return failure();
//   return success();
// }

template <typename OpTy>
LogicalResult printCStyleCastOp(CppEmitter &emitter, OpTy operation) {
  if (failed(emitter.emitAssignPrefix(*operation)))
    return failure();
  raw_ostream &os = emitter.ostream();
  os << "(";
  emitter.emitType(operation.getLoc(), operation->getResult(0).getType()); // require add type cast same to the operation's type
  os << ")"; 
  if (failed(emitter.emitOperands(*operation)))
    return failure();
  return success();
}

template <typename OpTy>
static LogicalResult printArithBinaryOp(CppEmitter &emitter, OpTy arithOp,
                                        StringRef opcode) {
  auto &os = emitter.ostream();

  auto lhs = arithOp.getLhs();
  auto rhs = arithOp.getRhs();

  if (failed(emitter.emitAssignPrefix(*arithOp.getOperation()))) {
    arithOp->emitError("cannot declare variable");
    return failure();
  }

  if (!emitter.hasValueInScope(lhs) || !emitter.hasValueInScope(rhs))
    return failure();

  os << "(" << emitter.getOrCreateName(lhs) << ") " << opcode << " ("
     << emitter.getOrCreateName(rhs) << ")";
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::ShLIOp lshOp) {
return printArithBinaryOp(emitter, lshOp, "<<");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::DivSIOp divOp) {
return printArithBinaryOp(emitter, divOp, "/");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::DivUIOp divOp) {
return printArithBinaryOp(emitter, divOp, "/");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::RemSIOp remOp) {
return printArithBinaryOp(emitter, remOp, "%");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::RemUIOp remOp) {
return printArithBinaryOp(emitter, remOp, "%");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::MulIOp mulOp) {
return printArithBinaryOp(emitter, mulOp, "*");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::DivFOp divOp) {
return printArithBinaryOp(emitter, divOp, "/");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::AddIOp addOp) {
return printArithBinaryOp(emitter, addOp, "+");
}
static LogicalResult printOperation(CppEmitter &emitter,
  arith::AddFOp addOp) {
return printArithBinaryOp(emitter, addOp, "+");
}
static LogicalResult printOperation(CppEmitter &emitter,
  arith::SubIOp subOp) {
return printArithBinaryOp(emitter, subOp, "-");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::AndIOp andOp) {
return printArithBinaryOp(emitter, andOp, "&");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::ShRUIOp shrOp) {
return printArithBinaryOp(emitter, shrOp, ">>");
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::MaxNumFOp maxOp) {
    auto &os = emitter.ostream();
    auto lhs = maxOp.getLhs();
    auto rhs = maxOp.getRhs();

    if (failed(emitter.emitAssignPrefix(*maxOp.getOperation())))
    return failure();

    if (!emitter.hasValueInScope(lhs) || !emitter.hasValueInScope(rhs))
    return failure();
    os << "__cn_scalar_max_f32(";
    os << emitter.getOrCreateName(lhs);
    os << ", ";
    os << emitter.getOrCreateName(rhs);
    os << ")";
    return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::CmpIOp &cmpOp) {
  auto &os = emitter.ostream();

  auto lhs = cmpOp.getLhs();
  auto rhs = cmpOp.getRhs();

  if (failed(emitter.emitAssignPrefix(*cmpOp.getOperation())))
  return failure();

  if (!emitter.hasValueInScope(lhs) || !emitter.hasValueInScope(rhs))
  return failure();

  os << emitter.getOrCreateName(lhs);

  switch (cmpOp.getPredicate()) {
  case arith::CmpIPredicate::eq:
  os << " == ";
  break;
  case arith::CmpIPredicate::ne:
  os << " != ";
  break;
  case arith::CmpIPredicate::sge:
  case arith::CmpIPredicate::uge:
  os << " >= ";
  break;
  case arith::CmpIPredicate::sgt:
  case arith::CmpIPredicate::ugt:
  os << " > ";
  break;
  case arith::CmpIPredicate::sle:
  case arith::CmpIPredicate::ule:
  os << " <= ";
  break;
  case arith::CmpIPredicate::slt:
  case arith::CmpIPredicate::ult:
  os << " < ";
  break;
  }

  os << emitter.getOrCreateName(rhs);

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
  arith::CmpFOp &cmpOp) {
  auto &os = emitter.ostream();

  auto lhs = cmpOp.getLhs();
  auto rhs = cmpOp.getRhs();

  if (failed(emitter.emitAssignPrefix(*cmpOp.getOperation())))
  return failure();

  if (!emitter.hasValueInScope(lhs) || !emitter.hasValueInScope(rhs))
  return failure();

  os << emitter.getOrCreateName(lhs);

  switch (cmpOp.getPredicate()) {
  case arith::CmpFPredicate::OEQ:
  os << " == ";
  break;
  case arith::CmpFPredicate::UNE:
  os << " != ";
  break;
  case arith::CmpFPredicate::OGE:
  os << " >= ";
  break;
  case arith::CmpFPredicate::OGT:
  os << " > ";
  break;
  case arith::CmpFPredicate::OLE:
  os << " <= ";
  break;
  case arith::CmpFPredicate::OLT:
  os << " < ";
  break;
  }

  os << emitter.getOrCreateName(rhs);

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    arith::IndexCastOp castOp) {
  raw_ostream &os = emitter.ostream();
  Operation &op = *castOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();
  os << "(";
  if (failed(emitter.emitType(op.getLoc(), op.getResult(0).getType())))
    return failure();
  os << ") ";
  os << emitter.getOrCreateName(castOp.getOperand());

  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    arith::SelectOp selectOp) {
  auto &os = emitter.ostream();

  auto cond = selectOp.getCondition();
  auto trueValue = selectOp.getTrueValue();
  auto falseValue = selectOp.getFalseValue();

  if (!emitter.hasValueInScope(cond) ||
      !emitter.hasValueInScope(trueValue) || !emitter.hasValueInScope(falseValue))
    return failure();
  
  if (failed(emitter.emitAssignPrefix(*(selectOp.getOperation()))))
    return failure();
  
  os << "(" << emitter.getOrCreateName(cond) << ") ? ("
     << emitter.getOrCreateName(trueValue) << ") : ("
     << emitter.getOrCreateName(falseValue) << ")";
  return success();
}

static LogicalResult printLLVMLdStOp(CppEmitter &emitter,
                                     LLVM::LoadOp loadOp) {
  auto &os = emitter.ostream();
  auto loc = loadOp.getLoc();

  auto resultType = loadOp.getType();
  auto addr = loadOp.getAddr();

  if (!emitter.hasValueInScope(addr))
    return failure();

  if (auto vecType = dyn_cast<VectorType>(resultType)) {
    auto eltType = vecType.getElementType();
    auto result = loadOp->getResult(0);
    if (!emitter.shouldDeclareVariablesAtTop()) {
      if (failed(emitter.emitVariableDeclaration(result, true)))
        return failure();
    }

    os << "__memcpy(" << emitter.getOrCreateName(result) << ", (";
    (void)emitter.emitType(loc, eltType);
    os << "*)" << emitter.getOrCreateName(addr) << ", "
       << vecType.getNumElements() * vecType.getElementTypeBitWidth() / 8
       << ", GDRAM2NRAM)";
  } else {
    if (failed(emitter.emitAssignPrefix(*loadOp.getOperation())))
      return failure();

    os << "*((";
    if (failed(emitter.emitType(loc, resultType)))
      return failure();
    
    os << "*) (" << emitter.getOrCreateName(addr) << "))";
  }
  return success(); 
}

static LogicalResult printMemRef(CppEmitter &emitter,
                                 Value addr, ValueRange indices) {
  auto &os = emitter.ostream();
  if (!emitter.hasValueInScope(addr))
    return failure();
  
  os << emitter.getOrCreateName(addr) << "[";

  if (indices.size() == 0) {
    os << "0";
  } else if (indices.size() == 1) {
    os << emitter.getOrCreateName(indices.front());
  } else { 
    SmallVector<int64_t> strides;
    int64_t offset;

    if (failed(getStridesAndOffset(cast<MemRefType>(addr.getType()),
                                   strides, offset)))
      return failure();

    assert(strides.size() == indices.size());
    for (auto [index, stride] : llvm::zip(indices, strides)) {
      os << stride << "*" << emitter.getOrCreateName(index) << " + ";
    }
    os << " " << offset;
  }

  os << "]";
  return success();  
}

static LogicalResult printMemrefLdStOp(CppEmitter &emitter,
                                       memref::LoadOp loadOp) {
  auto &os = emitter.ostream();
  auto loc = loadOp.getLoc();

  auto resultType = loadOp.getType();
  auto addr = loadOp.getMemref();
  if (failed(emitter.emitAssignPrefix(*loadOp.getOperation())))
    return failure();
  if (failed(printMemRef(emitter, addr, loadOp.getIndices())))
    return failure();
  return success();
}

static LogicalResult printMemrefLdStOp(CppEmitter &emitter,
                                       memref::StoreOp storeOp) {
  auto &os = emitter.ostream();
  auto loc = storeOp.getLoc();
  auto value = storeOp.getValue();
  auto addr = storeOp.getMemRef();

  auto resultType = storeOp.getValue().getType();
  if (failed(emitter.emitAssignPrefix(*storeOp.getOperation())))
    return failure();
  if (failed(printMemRef(emitter, addr, storeOp.getIndices())))
    return failure();
  
  os << " = " << emitter.getOrCreateName(value);

  return success();
}

static LogicalResult printLLVMLdStOp(CppEmitter &emitter,
                                     LLVM::StoreOp storeOp) {
  auto &os = emitter.ostream();
  auto loc = storeOp.getLoc();

  auto value = storeOp.getValue();
  auto addr  = storeOp.getAddr();

  if (auto vecType = dyn_cast<VectorType>(value.getType())) {
    auto eltType = vecType.getElementType();

    os << "__memcpy((";
    (void)emitter.emitType(loc, eltType);
    os << "*)" << emitter.getOrCreateName(addr) << ", "
       << emitter.getOrCreateName(value) << ", "
       << vecType.getNumElements() * vecType.getElementTypeBitWidth() / 8
       << ", NRAM2GDRAM)";
  } else {
    os << "*(";

    if (failed(emitter.emitType(loc, value.getType())))
      return failure();
    
    os << "*)(" << emitter.getOrCreateName(addr) << ")"
      << " = " << emitter.getOrCreateName(value);
  }

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

    llvm::dbgs() << "\nICT_DEBUG(): " << llvmGEPOp << "\n";
    auto indices = llvmGEPOp.getRawConstantIndices();

    assert(llvmGEPOp.getElemType().has_value());

    unsigned offset = 0, dynamicIndex = 0;
    Type elemType = LLVM::LLVMArrayType::get(llvmGEPOp.getElemType().value(), 1);
    auto moduleOp = llvmGEPOp->getParentOfType<ModuleOp>();

    DataLayout dataLayout(moduleOp);

    os << "((int8_t*)" << emitter.getOrCreateName(llvmGEPOp.getBase());

    for (auto index : indices) {
      assert(elemType != nullptr);
      llvm::dbgs() << "\tindex is " << index << "\n"
                   << "\telemType is " << elemType << "\n"
                   << "\toffset is " << offset << "\n";

      bool isDynamic = (index == LLVM::GEPOp::kDynamicIndex);
      
      if (auto structType = dyn_cast<LLVM::LLVMStructType>(elemType)) {
        assert(structType.isPacked() && !isDynamic);

        auto elemTypes = structType.getBody();
        assert(elemTypes.size() > index);

        for (int32_t j = 0; j < index; j++) {
          offset += dataLayout.getTypeSize(elemTypes[j]);
        }
        elemType = elemTypes[index];
      } else if (auto arrayType = dyn_cast<LLVM::LLVMArrayType>(elemType)) {
        elemType = arrayType.getElementType();
        if (isDynamic) {
          os << " + " << emitter.getOrCreateName(llvmGEPOp->getOperand(++dynamicIndex))
             << " * " << dataLayout.getTypeSize(elemType);
        } else {
          offset += (index * dataLayout.getTypeSize(elemType));
        }
      } else {
        return llvmGEPOp->emitOpError("ICT_ERROR(): Unsupport elemType for GEPOp: ")
          << elemType;
      }
    }
    
    if (offset > 0) {
      llvm::dbgs() << "\toffset = " << offset << "\n";
      os << " + " << offset;
    }
    os << ")";

    //   if (failed(emitter.emitAddLikeOperands(*(llvmGEPOp.getOperation()))))
    //     return failure();
    //   // Here, has print: __gm__ float *%4 = (__gm__ float *)%0 + %3;

    return success();
  }
  return failure();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
  npu::VMaxF32Op maxOp) {
    auto &os = emitter.ostream();
    auto result = maxOp->getResult(0);
    if (!emitter.shouldDeclareVariablesAtTop()) {
      if (failed(emitter.emitVariableDeclaration(result, true)))
        return failure();
    }

    if (!emitter.hasValueInScope(maxOp.getLhs()) ||
        !emitter.hasValueInScope(maxOp.getRhs())) {
      return maxOp->emitOpError("ICT_ERROR(): operator was not defined!");
    }
    os << "__cn_vector_max_f32(";

    auto dstType = maxOp.getType();
    auto dstElemType = dstType.getElementType();
    // npu binary's addrsapce must be 6.
    auto dstPtrType = LLVM::LLVMPointerType::get(dstElemType, 6);

    auto numElems = maxOp.getNumElems();
    if (numElems % 8 != 0) {
      return maxOp->emitOpError("ICT_ERROR(): npu vmax_f32 op's numElems is not multiple of 8!");
    }

    os << numElems << ", "
       << "(float *)" << emitter.getOrCreateName(maxOp.getRes()) << ", "
       << "(float *)" << emitter.getOrCreateName(maxOp.getLhs()) << ", "
       << "(float *)" << emitter.getOrCreateName(maxOp.getRhs()) << ")";
    return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MovUBToUBWriteOp movOp) {
  auto &os = emitter.ostream();
  auto vecTy = movOp.getValueToStore().getType();

  os << "__memcpy(" << emitter.getOrCreateName(movOp.getDstAddr())
     << ", " << emitter.getOrCreateName(movOp.getValueToStore()) 
     << ", " << vecTy.getNumElements() * vecTy.getElementTypeBitWidth()/8 << ", NRAM2NRAM)";
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MovUBToUBReadOp movOp) {
  auto &os = emitter.ostream();
  auto vecTy = movOp.getRes().getType();

  Operation::result_range results = movOp->getResults();
  if (!emitter.shouldDeclareVariablesAtTop()) {
    for (OpResult result : results) {
      if (failed(emitter.emitVariableDeclaration(result,
                                                 /*trailingSemicolon=*/true)))
        return failure();
    }
  }

  os << "__memcpy(" << emitter.getOrCreateName(movOp.getRes())
  << ", " << emitter.getOrCreateName(movOp.getSrcAddr()) 
  << ", " << vecTy.getNumElements() * vecTy.getElementTypeBitWidth() / 8 << ", NRAM2NRAM)";
  return success();
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
  Operation::result_range results = movOutToUBOp->getResults();
  if (!emitter.shouldDeclareVariablesAtTop()) {
    for (OpResult result : results) {
      if (failed(emitter.emitVariableDeclaration(result,
                                                 /*trailingSemicolon=*/true)))
        return failure();
    }
  }
  // os << "copy_gm_to_ubuf((__ubuf__ ";   // callee name
  os << "__memcpy(";   // callee name

  auto movType = movOutToUBOp.getRes().getType();   // Res type is vector<Nxf32>
  // TODO: Here should modify emitType() to print VectorType, but it has no
  // addrspace info, so temporarily process it here.
  assert(isa<VectorType>(movType) &&
         "ICT_ERROR(): mov_out_to_ub's res type is not vector type!");
  auto vecType = movType.cast<VectorType>();

  auto elemType = vecType.getElementType();   // vector's element type, such as float
  // if(failed(emitter.emitType(movOutToUBOp.getLoc(), elemType)))
  //   return failure();
  // os << " *)";
  os << emitter.getOrCreateName(movOutToUBOp.getRes());
  // Here, has print: copy_gm_to_ubuf((__ubuf__ float *)i5, 

  // os << ", (__gm__ ";
  os << ", ";
  // if(failed(emitter.emitType(movOutToUBOp.getLoc(), elemType)))
  //   return failure();
  // os << " *)";
  os << emitter.getOrCreateName(movOutToUBOp.getSrcAddr());
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
  // if(numElems > 256) {
  //   return emitError(movOutToUBOp.getLoc(),
  //                    "ICT_ERROR(): mov_out_to_ub's res type's numElems is larger "
  //                    "than 256!");
  // }
  auto burstLen = numElems * elemType.getIntOrFloatBitWidth() / 8;
  // os << ", 0, 1, " << burstLen << ", 0, 0)";
  os << ", " << burstLen << ", GDRAM2NRAM)";
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
  // os << "copy_ubuf_to_gm((__gm__ ";   // callee name
  os << "__memcpy(";   // callee name
  // get mov_ub_to_out's element type.
  auto movType = movUBToOUTOp.getValueToStore().getType();   // Res type is vector<Nxf32>
  assert(isa<VectorType>(movType) &&
         "ICT_ERROR(): mov_ub_to_out's res type is not vector type!");
  
  auto vecType = movType.cast<VectorType>();

  auto elemType = vecType.getElementType(); // vector's element type, such as float
  // if(failed(emitter.emitType(movUBToOUTOp.getLoc(), elemType)))
    // return failure();
  // os << " *)";
  os << emitter.getOrCreateName(movUBToOUTOp.getDstAddr());
  // Here, has print: copy_ubuf_to_gm((__gm__ float *)i9,

  // os << ", (__ubuf__ ";
  os << ", ";
  // if(failed(emitter.emitType(movUBToOUTOp.getLoc(), elemType)))
  //   return failure();
  // os << " *)";
  os << emitter.getOrCreateName(movUBToOUTOp.getValueToStore());
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
  // if(numElems > 256) {
  //   return emitError(movUBToOUTOp.getLoc(),
  //                    "ICT_ERROR(): mov_ub_to_out's res type's numElems is larger "
  //                    "than 256!");
  // }
  auto burstLen = numElems * elemType.getIntOrFloatBitWidth() / 8;
  // os << ", 0, 1, " << burstLen << ", 0, 0)";
  os << ", " << burstLen << ", NRAM2GDRAM)";
  // Here has print:
  //   copy_ubuf_to_gm((__gm__ float *)i9, (__ubuf__ float *)i8, 0, 1, 1, 0, 0);
  return success();
}

static LogicalResult
printNPUOp(CppEmitter &emitter, npu::LoadF32Op loadOp) {
  auto &os = emitter.ostream();
  auto result = loadOp->getResult(0);
  if (failed(emitter.emitAssignPrefix(*loadOp.getOperation()))) {
    return failure();
  }

  if (!emitter.hasValueInScope(loadOp.getSrcVector())) {
    return loadOp->emitOpError("ICT_ERROR(): operator was not defined!");
  }

  os << emitter.getOrCreateName(loadOp.getSrcVector()) << "[0]";
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter, npu::AtomicAddF32Op op) {
  auto &os = emitter.ostream();

  auto dstAddr = op.getDstAddr();
  auto valueToAdd = op.getValueToAdd();
  auto numElems = op.getNumElems();

  if (!emitter.hasValueInScope(dstAddr) ||
      !emitter.hasValueInScope(valueToAdd)) {
    return op->emitOpError("ICT_ERROR(): operator not defined!");
  }

  if(numElems % 8 != 0) {
    return op->emitOpError("ICT_ERROR(): atomic_add's res type's numElems is not "
                     "multiple of 8!");
  }

  os << "__bang_atomic_add(" << emitter.getOrCreateName(valueToAdd)
     << ", " << emitter.getOrCreateName(dstAddr) << ", "
     << emitter.getOrCreateName(valueToAdd) << ", "
     << numElems << ")";
  return success();
}

// Generic emitter for npu unary operations.
template <typename OpTy>
static LogicalResult printNPUUnaryOp(CppEmitter &emitter,
                                     OpTy npuUOp) {
  auto &os = emitter.ostream();
  auto result = npuUOp->getResult(0);
  if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }

  if (!emitter.hasValueInScope(npuUOp->getOperand(0))) {
    return npuUOp->emitOpError("ICT_ERROR(): operator was not defined!");
  }

  auto intrinsic = llvm::StringSwitch<StringRef>(npuUOp->getName().stripDialect())
      .Case("vtanh_f32", "__bang_active_tanh")
      .Case("vexp_f32", "__bang_active_exp")
      .Case("vrecip_f32", "__bang_active_recip")
      .Case("vsigmoid_f32", "__bang_active_sigmoid")
      .Case("movev_f32", "__bang_move") // FIXME
      .Default(""); // TODO
  
  if (intrinsic.empty())
    return npuUOp->emitOpError("ICT_ERROR(): unknown npu unary op!");

  os << intrinsic << "(";

  auto dstType = npuUOp.getType();
  auto dstElemType = dstType.getElementType();
  // npu binary's addrsapce must be 6.
  auto dstPtrType = LLVM::LLVMPointerType::get(dstElemType, 6);
  
  os << emitter.getOrCreateName(npuUOp.getRes()) << ", "
     << emitter.getOrCreateName(npuUOp->getOperand(0)) << ", ";
  
  auto numElems = npuUOp.getNumElems();
  if (numElems % 8 != 0) {
    return npuUOp->emitOpError("ICT_ERROR(): npu binary op's numElems is not multiple of 8!");
  }
   
  os << numElems << ")";
  return success();
}

// Generic emitter for npu binary operations.
template <typename OpTy>
static LogicalResult printNPUBinOp(CppEmitter &emitter,
                                   OpTy npuBinOp) {
  auto &os = emitter.ostream();
  auto result = npuBinOp->getResult(0);
  if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }

  if (!emitter.hasValueInScope(npuBinOp.getLhs()) ||
      !emitter.hasValueInScope(npuBinOp.getRhs())) {
    return npuBinOp->emitOpError("ICT_ERROR(): operator was not defined!");
  }

  auto intrinsic = llvm::StringSwitch<StringRef>(npuBinOp->getName().stripDialect())
      .Cases("vadd_f32", "vadd", "__bang_add")
      .Cases("vsub_f32", "vsub", "__bang_sub")
      .Cases("vmul_f32", "vmul", "__bang_mul")
      .Cases("vdiv_f32", "vdiv", "__bang_div")
      .Default("");
  
  if (intrinsic.empty())
    return npuBinOp->emitOpError("ICT_ERROR(): unknown binary op!");
  
  os << intrinsic;

  if (!isa<VectorType>(npuBinOp.getRhs().getType()))
    os << "_scalar";
  
  os << "(";

  auto dstType = npuBinOp.getType();
  auto dstElemType = dstType.getElementType();
  // npu binary's addrsapce must be 6.
  auto dstPtrType = LLVM::LLVMPointerType::get(dstElemType, 6);
  
  os << emitter.getOrCreateName(npuBinOp.getRes()) << ", "
     << emitter.getOrCreateName(npuBinOp.getLhs()) << ", "
     << emitter.getOrCreateName(npuBinOp.getRhs()) << ", ";

  auto numElems = npuBinOp.getNumElems();
  if (numElems % 8 != 0) {
    return npuBinOp->emitOpError("ICT_ERROR(): npu binary op's numElems is not multiple of 8!");
  }

  os << numElems << ")";
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

#define DEFINE_NPU_BINOP_EMITTER(OpTy) \
static LogicalResult printNPUOp(CppEmitter &emitter,\
                                npu::OpTy op) { \
  return printNPUBinOp<>(emitter, op); \
}

DEFINE_NPU_BINOP_EMITTER(VAddF32Op)
DEFINE_NPU_BINOP_EMITTER(VSubF32Op)
DEFINE_NPU_BINOP_EMITTER(VMulF32Op)
// DEFINE_NPU_BINOP_EMITTER(VDivF32Op)

#undef DEFINE_NPU_BINOP_EMITTER

#define DEFINE_NPU_UNARYOP_EMITTER(OpTy) \
static LogicalResult printNPUOp(CppEmitter &emitter, OpTy op) {\
  return printNPUUnaryOp<>(emitter, op); \
}

DEFINE_NPU_UNARYOP_EMITTER(npu::VExpF32Op)
DEFINE_NPU_UNARYOP_EMITTER(npu::VTanhF32Op)
DEFINE_NPU_UNARYOP_EMITTER(npu::VRecipF32Op)
DEFINE_NPU_UNARYOP_EMITTER(npu::VSigmoidF32Op)
// DEFINE_NPU_UNARYOP_EMITTER(npu::MOVEVF32Op)

#undef DEFINE_NPU_UNARYOP_EMITTER

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MOVEVF32Op op) {
  auto &os = emitter.ostream();
  auto result = op->getResult(0);
  if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }

  if (!emitter.hasValueInScope(op->getOperand(0))) {
    return op->emitOpError("ICT_ERROR(): operator was not defined!");
  }

  auto numElems = op.getNumElems();
  if (numElems % 8 != 0) {
    return op->emitOpError("ICT_ERROR(): npu binary op's numElems is not multiple of 8!");
  }

  os << "__bang_write_value(" << emitter.getOrCreateName(result)
     << ", " << numElems << ", "
     << emitter.getOrCreateName(op->getOperand(0)) << ")";

  return success();  
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::BlockIdOp blockId) {
  auto &os = emitter.ostream();

  if (failed(emitter.emitAssignPrefix(*blockId.getOperation())))
    return failure();
  
  os << "taskId" << blockId.getDimension();
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::BlockNumOp blockNum) {
  auto &os = emitter.ostream();

  if (failed(emitter.emitAssignPrefix(*blockNum.getOperation())))
    return failure();
                                  
  os << "taskDim" << blockNum.getDimension();
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::AllocaOp allocaOp) {
  auto &os = emitter.ostream();

  if (allocaOp->use_empty())
    os << "// ";

  os << "__nram__ int8_t "
     << emitter.getOrCreateName(allocaOp) << "["
     << allocaOp.getNumElems() << "]";

  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::TransposeOp transOp) {
  auto &os = emitter.ostream();
  auto result = transOp->getResult(0);

  if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }
  
  os << "__bang_transpose(" << emitter.getOrCreateName(result)
     << ", " << emitter.getOrCreateName(transOp.getInput()) << ", "
     << transOp.getNumRows() << ", " << transOp.getNumCols() << ")";
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::ReshapeFilterOp reshapeOp) {
  auto &os = emitter.ostream();
  auto result = reshapeOp->getResult(0);

  // if (!emitter.shouldDeclareVariablesAtTop()) {
  //   if (failed(emitter.emitVariableDeclaration(result, true)))
  //     return failure();
  // }

  auto input = reshapeOp.getInput();
  auto transOp = input.getDefiningOp<npu::TransposeOp>();
  assert(transOp != nullptr && "Input of reshape_filter is not a transpose!");

  // Try to reuse the buffer of the input vector of transpose op.
  // TODO(wcao): Implement a static memory planner to do memory reuse!!
  input = transOp.getInput();
  if (llvm::range_size(input.getUsers()) == 1) {
    emitter.createValueName(result, emitter.getOrCreateName(input));
  } else if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }
  
  os << "__bang_reshape_filter(" << emitter.getOrCreateName(result)
     << ", " << emitter.getOrCreateName(reshapeOp.getInput()) << ", "
     << reshapeOp.getBatch() << ", " << reshapeOp.getChannels() << ", "
     << reshapeOp.getHeight() << ", " << reshapeOp.getWidth() << ")";
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::MlpOp mlpOp) {
  auto &os = emitter.ostream();
  auto result = mlpOp->getResult(0);

  if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }
  
  auto filter = mlpOp.getFilter();
  auto filterType = cast<VectorType>(filter.getType());

  // Declare a wram buffer with the same size of the filter vector,
  // and copy the filter data from npu to wram.
  os << "__wram__ ";
  if (failed(emitter.emitType(mlpOp.getLoc(), filterType.getElementType())))
    return failure();
  
  os << " " << emitter.getOrCreateName(filter) << "_wram["
     << filterType.getNumElements() << "];\n";
  
  os << "__memcpy(" << emitter.getOrCreateName(filter) << "_wram, "
     << emitter.getOrCreateName(filter) << ", "
     << filterType.getNumElements() * filterType.getElementType().getIntOrFloatBitWidth() / 8
     << ", NRAM2WRAM);\n";
  
  // Invoke the __bang_mlp intrisinc function.
  os << "__bang_mlp(" << emitter.getOrCreateName(result) << ", "
     << emitter.getOrCreateName(mlpOp.getInput()) << ", "
     << emitter.getOrCreateName(filter) << "_wram, "
     << mlpOp.getNumRows() << ", " << mlpOp.getNumCols() << ")";

  return success();           
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::VReduceF32Op op) {
  auto &os = emitter.ostream();
  if (failed(emitter.emitAssignPrefix(*op.getOperation())))
    return failure();
  
  os << "__cn_vector_reduce_" << op.getKind()
     << "_f32((float*)" << emitter.getOrCreateName(op.getInput())
     << ", " << op.getNumElems() << ")";
  return success();
}

static LogicalResult printNPUOp(CppEmitter &emitter,
                                npu::VFusionF32Op op) {
  auto &os = emitter.ostream();
  auto result = op->getResult(0);

  if (!emitter.shouldDeclareVariablesAtTop()) {
    if (failed(emitter.emitVariableDeclaration(result, true)))
      return failure();
  }

  os << "__bang_fusion(" << op.getKind() << ", "
     << emitter.getOrCreateName(result) << ", "
     << emitter.getOrCreateName(op.getSrc0()) << ", "
     << emitter.getOrCreateName(op.getSrc1()) << ", "
     << emitter.getOrCreateName(op.getSrc2()) << ", "
     << op.getNumSrcElems();
  
  if (op.getNumSegElems().has_value()) {
    os << ", " << op.getNumSegElems().value();
  }

  os << ")";
  return success();
}

static LogicalResult printBinaryOperation(CppEmitter &emitter,
                                          Operation *operation,
                                          StringRef binaryOperator) {
  raw_ostream &os = emitter.ostream();

  if (failed(emitter.emitAssignPrefix(*operation)))
    return failure();
  os << emitter.getOrCreateName(operation->getOperand(0));
  os << " " << binaryOperator;
  os << " " << emitter.getOrCreateName(operation->getOperand(1));

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

  os << "if (" << emitter.getOrCreateName(condBranchOp.getCondition())
     << ") {\n";

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

static LogicalResult printOperation(CppEmitter &emitter, func::CallOp callOp) {
  if (failed(emitter.emitAssignPrefix(*callOp.getOperation())))
    return failure();

  raw_ostream &os = emitter.ostream();
  os << callOp.getCallee() << "(";
  if (failed(emitter.emitOperands(*callOp.getOperation())))
    return failure();
  os << ")";
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter, emitc::CallOp callOp) {
  raw_ostream &os = emitter.ostream();
  Operation &op = *callOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();
  os << callOp.getCallee();

  auto emitArgs = [&](Attribute attr) -> LogicalResult {
    if (auto t = dyn_cast<IntegerAttr>(attr)) {
      // Index attributes are treated specially as operand index.
      if (t.getType().isIndex()) {
        int64_t idx = t.getInt();
        if ((idx < 0) || (idx >= op.getNumOperands()))
          return op.emitOpError("invalid operand index");
        if (!emitter.hasValueInScope(op.getOperand(idx)))
          return op.emitOpError("operand ")
                 << idx << "'s value not defined in scope";
        os << emitter.getOrCreateName(op.getOperand(idx));
        return success();
      }
    }
    if (failed(emitter.emitAttribute(op.getLoc(), attr)))
      return failure();

    return success();
  };

  if (callOp.getTemplateArgs()) {
    os << "<";
    if (failed(
            interleaveCommaWithError(*callOp.getTemplateArgs(), os, emitArgs)))
      return failure();
    os << ">";
  }

  os << "(";

  LogicalResult emittedArgs =
      callOp.getArgs()
          ? interleaveCommaWithError(*callOp.getArgs(), os, emitArgs)
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

static LogicalResult printOperation(CppEmitter &emitter, emitc::CastOp castOp) {
  raw_ostream &os = emitter.ostream();
  Operation &op = *castOp.getOperation();

  if (failed(emitter.emitAssignPrefix(op)))
    return failure();
  os << "(";
  if (failed(emitter.emitType(op.getLoc(), op.getResult(0).getType())))
    return failure();
  os << ") ";
  os << emitter.getOrCreateName(castOp.getOperand());

  return success();
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

static LogicalResult printOperation(CppEmitter &emitter, scf::ForOp forOp) {

  raw_indented_ostream &os = emitter.ostream();

  OperandRange operands = forOp.getInitArgs();
  Block::BlockArgListType iterArgs = forOp.getRegionIterArgs();
  Operation::result_range results = forOp.getResults();

  auto genMoveNRam = [&](Value dst, Value src) -> LogicalResult {
    if (dst.getType() != src.getType())
      return failure();
    
    if (auto vecType = dyn_cast<VectorType>(dst.getType())) {
      os << "__memcpy(" << emitter.getOrCreateName(dst) << ", "
         << emitter.getOrCreateName(src) << ", " << vecType.getNumElements()
         << " * sizeof(";
      if (failed(emitter.emitType(forOp.getLoc(), vecType.getElementType())))
        return failure();
      
      os << "), NRAM2NRAM);";
      return success();
    }
    return failure();
  };

  if (!emitter.shouldDeclareVariablesAtTop()) {
    for (OpResult result : results) {
      if (failed(emitter.emitVariableDeclaration(result,
                                                 /*trailingSemicolon=*/true)))
        return failure();
    }
  }

  for (auto pair : llvm::zip(iterArgs, operands)) {
    auto iterArg = std::get<0>(pair);
    auto iterType = iterArg.getType();

    if (auto vecType = dyn_cast<VectorType>(iterType)) {
      auto iterVal = results[iterArg.getArgNumber()-1];
      emitter.createValueName(iterArg, emitter.getOrCreateName(results[iterArg.getArgNumber()-1]));
      if (failed(genMoveNRam(iterArg, std::get<1>(pair))))
        return failure();  
    } else {
      if (failed(emitter.emitType(forOp.getLoc(), std::get<0>(pair).getType())))
        return failure();
      os << " " << emitter.getOrCreateName(std::get<0>(pair)) << " = ";
      os << emitter.getOrCreateName(std::get<1>(pair)) << ";";
    }
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
    if (auto vecType = dyn_cast<VectorType>(operand.getType())) {
      if (failed(genMoveNRam(iterArg, operand)))
        return failure();
      os << "\n";
    } else {
      os << emitter.getOrCreateName(iterArg) << " = "
         << emitter.getOrCreateName(operand) << ";\n";
    }
  }

  os.unindent() << "}";

  // Copy iterArgs into results after the for loop.
  for (auto pair : llvm::zip(results, iterArgs)) {
    OpResult result = std::get<0>(pair);
    BlockArgument iterArg = std::get<1>(pair);

    if (auto vecType = dyn_cast<VectorType>(iterArg.getType())) {
      os << "\n";
      //if (failed(genMoveNRam(result, iterArg)))
      //  return failure();
    } else {
      os << "\n"
          << emitter.getOrCreateName(result) << " = "
          << emitter.getOrCreateName(iterArg) << ";";
    }
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
  if (failed(emitter.emitOperands(*ifOp.getOperation())))
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
    os << " " << emitter.getOrCreateName(returnOp.getOperand(0));
    return success(emitter.hasValueInScope(returnOp.getOperand(0)));
  default:
    os << " std::make_tuple(";
    if (failed(emitter.emitOperandsAndAttributes(*returnOp.getOperation())))
      return failure();
    os << ")";
    return success();
  }
}

static LogicalResult printOperation(CppEmitter &emitter, ModuleOp moduleOp) {
  CppEmitter::Scope scope(emitter);

  for (Operation &op : moduleOp) {
    if (failed(emitter.emitOperation(op, /*trailingSemicolon=*/false)))
      return failure();
  }
  return success();
}

static LogicalResult printOperation(CppEmitter &emitter,
                                    gpu::GPUModuleOp gpuModuleOp) {
  CppEmitter::Scope scope(emitter);
  emitter.ostream() << "#include <bang.h>\n";
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

  CppEmitter::Scope scope(emitter);
  raw_indented_ostream &os = emitter.ostream();
  if (failed(emitter.emitTypes(functionOp.getLoc(),
                               functionOp.getFunctionType().getResults())))
    return failure();
  os << " " << functionOp.getName();

  os << "(";
  if (failed(interleaveCommaWithError(
          functionOp.getArguments(), os,
          [&](BlockArgument arg) -> LogicalResult {
            if (failed(emitter.emitType(functionOp.getLoc(), arg.getType())))
              return failure();
            os << " " << emitter.getOrCreateName(arg);
            return success();
          })))
    return failure();
  os << ") {\n";
  os.indent();
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
      bool trailingSemicolon =
          !isa<cf::CondBranchOp, emitc::LiteralOp, emitc::IfOp, scf::ForOp>(op);

      if (failed(emitter.emitOperation(
              op, /*trailingSemicolon=*/trailingSemicolon)))
        return failure();
    }
  }
  os.unindent() << "}\n";
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
  // if 910B3
  // os << "extern \"C\" __global__ [aicore] ";
  // if bang
  os << "__mlu_global__ ";
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
      bool trailingSemicolon =
          !isa<cf::CondBranchOp, emitc::LiteralOp, emitc::IfOp, scf::ForOp>(op);

      if (failed(emitter.emitOperation(
              op, /*trailingSemicolon=*/trailingSemicolon)))
        return failure();
    }
  }
  os.unindent() << "}\n";
  return success();
}

CppEmitter::CppEmitter(raw_ostream &os, bool declareVariablesAtTop)
    : os(os), declareVariablesAtTop(declareVariablesAtTop) {
  valueInScopeCount.push(0);
  labelInScopeCount.push(0);
}

void CppEmitter::createValueName(Value val, StringRef name) {
  assert(!valueMapper.count(val) && "The value already has a name!");
  llvm::dbgs() << "\n[ICT-DEBUG]: Binding name '" << name << "' to value " << val << "\n";
  valueMapper.insert(val, name.str());
}

/// Return the existing or a new name for a Value.
StringRef CppEmitter::getOrCreateName(Value val) {
  if (auto literal = dyn_cast_if_present<emitc::LiteralOp>(val.getDefiningOp()))
    return literal.getValue();
  if (!valueMapper.count(val)) {
    APInt intVal;
    if (matchPattern(val, m_ConstantInt(&intVal))) {
      valueMapper.insert(val, formatv("c{0}_{1}", intVal.getZExtValue(),
          ++valueInScopeCount.top()));
    } else {
      valueMapper.insert(val, formatv("v{0}", ++valueInScopeCount.top()));
    }
  }
  return *valueMapper.begin(val);
}

/// Return the existing or a new label for a Block.
StringRef CppEmitter::getOrCreateName(Block &block) {
  if (!blockMapper.count(&block))
    blockMapper.insert(&block, formatv("label{0}", ++labelInScopeCount.top()));
  return *blockMapper.begin(&block);
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
      switch (llvm::APFloatBase::SemanticsToEnum(val.getSemantics())) {
      case llvm::APFloatBase::S_IEEEsingle:
        os << "(float)";
        break;
      case llvm::APFloatBase::S_IEEEdouble:
        os << "(double)";
        break;
      default:
        break;
      };
      os << strValue;
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
    printFloat(fAttr.getValue());
    return success();
  }
  if (auto dense = dyn_cast<DenseFPElementsAttr>(attr)) {
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

LogicalResult CppEmitter::emitOperands(Operation &op) {
  auto emitOperandName = [&](Value result) -> LogicalResult {
    if (!hasValueInScope(result))
      return op.emitOpError() << "operand value not in scope";
    os << getOrCreateName(result);
    return success();
  };
  return interleaveCommaWithError(op.getOperands(), os, emitOperandName);
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
  if (hasValueInScope(result)) {
    return result.getDefiningOp()->emitError(
        "result variable for the operation already declared");
  }

  auto owner = result.getOwner();

  if (isa<VectorType>(result.getType()) &&
      !isa<UnrealizedConversionCastOp>(owner)) {
    auto vecType = cast<VectorType>(result.getType());
    os << "__nram__ ";
    // For MLU device, we treat vector type as its element type
    if (failed(emitType(owner->getLoc(), vecType.getElementType())))
      return failure();
    os << " " << getOrCreateName(result);
    os << "[" << vecType.getNumElements() << "];\n";
    return success();
  }

  if (failed(emitType(result.getOwner()->getLoc(), result.getType())))
    return failure();
  os << " " << getOrCreateName(result);
  if (trailingSemicolon)
    os << ";\n";
  return success();
}

LogicalResult CppEmitter::emitAssignPrefix(Operation &op) {
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
          .Case<emitc::AddOp, emitc::ApplyOp, emitc::AssignOp, emitc::CallOp,
                emitc::CastOp, emitc::CmpOp, emitc::ConstantOp, emitc::DivOp,
                emitc::IfOp, emitc::IncludeOp, emitc::MulOp, emitc::RemOp,
                emitc::SubOp, emitc::VariableOp>(
              [&](auto op) { return printOperation(*this, op); })
          // Func ops.
          .Case<func::CallOp, func::ConstantOp, func::FuncOp, func::ReturnOp>(
              [&](auto op) { return printOperation(*this, op); })
          // SCF ops.
          .Case<scf::ForOp, scf::YieldOp>(
              [&](auto op) { return printOperation(*this, op); })
          // Arithmetic ops.
          .Case<arith::ConstantOp, arith::SelectOp,
                arith::AddIOp, arith::ShLIOp, arith::DivSIOp,
                arith::RemSIOp, arith::DivUIOp, arith::RemUIOp,
                arith::MulIOp, arith::CmpIOp, arith::SubIOp,
                arith::ShRUIOp, arith::MaxNumFOp,
                arith::AddFOp, arith::AndIOp, arith::DivFOp,
                arith::CmpFOp, arith::IndexCastOp>(
              [&](auto op) { return printOperation(*this, op); })
          .Case<emitc::LiteralOp>([&](auto op) { return success(); })
          // GPU ops.
          .Case<gpu::GPUModuleOp, gpu::GPUFuncOp, gpu::ReturnOp,
                gpu::ModuleEndOp>(
              [&](auto op) { return printOperation(*this, op); })
          // Builtin.xx ops.
          .Case<UnrealizedConversionCastOp>([&](auto op) {
            //return printBuiltinUnrealizedConversionOp(*this, op);
            return printCStyleCastOp(*this, op);
          })
          // LLVM ops.
          .Case<LLVM::GEPOp>([&](auto op) { return printLLVMGEPOp(*this, op); })
          .Case<LLVM::LoadOp, LLVM::StoreOp>([&](auto op) { return printLLVMLdStOp(*this, op); })
          .Case<LLVM::ConstantOp>([&](auto op) { return printOperation(*this, op); })
          .Case<memref::LoadOp, memref::StoreOp>([&](auto op) { return printMemrefLdStOp(*this, op); })
          // NPU ops.
          .Case<npu::MovOutToUBOp, npu::MovUBToOutOp,
                npu::MovUBToUBWriteOp, npu::MovUBToUBReadOp,
                npu::VAddF32Op, npu::VSubF32Op, npu::VMulF32Op,
                npu::VTanhF32Op, npu::VExpF32Op, npu::VRecipF32Op,
                npu::VSigmoidF32Op, npu::VMaxF32Op,
                npu::MOVEVF32Op, npu::BlockIdOp, npu::BlockNumOp,
                npu::LoadF32Op, npu::AtomicAddF32Op,
                npu::MlpOp, npu::TransposeOp, npu::ReshapeFilterOp,
                npu::AllocaOp, npu::VReduceF32Op, npu::VFusionF32Op>(
              [&](auto op) { return printNPUOp(*this, op); })
          .Default([&](Operation *) {
            return op.emitOpError("unable to find printer for op");
          });

  if (failed(status))
    return failure();

  if (isa<emitc::LiteralOp>(op))
    return success();

  os << (trailingSemicolon ? ";\n" : "\n");
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
    case 32:
      return (os << "float"), success();
    case 64:
      return (os << "double"), success();
    default:
      return emitError(loc, "cannot emit float type ") << type;
    }
  }
  if (auto iType = dyn_cast<IndexType>(type))
    return (os << "size_t"), success();
  if (auto tType = dyn_cast<TensorType>(type)) {
    if (!tType.hasRank())
      return emitError(loc, "cannot emit unranked tensor type");
    if (!tType.hasStaticShape())
      return emitError(loc, "cannot emit tensor type with non static shape");
    os << "Tensor<";
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
  if (auto pType = dyn_cast<emitc::PointerType>(type)) {
    if (failed(emitType(loc, pType.getPointee())))
      return failure();
    os << "*";
    return success();
  }
  if (auto memrefType = dyn_cast<MemRefType>(type)) {
    // Emit memory space.
    // if (memrefType.getMemorySpaceAsInt() == 1) {
    //   os << "__gm__ ";
    // } else if (memrefType.getMemorySpaceAsInt() == 6) {
    //   os << "__ubuf__ ";
    // } else {
    //   return emitError(loc, "ICT_ERROR(): cannot emit MemRef memory space: ")
    //          << memrefType.getMemorySpaceAsInt();
    // }
    // Emit element type.
    if (auto fType = dyn_cast<FloatType>(memrefType.getElementType())) {
      if (fType.getWidth() == 32)
        os << "float";
      else
        return emitError(loc, "ICT_ERROR(): cannot emit MemRef float type "
                              "which width != 32: ")
               << fType;
    } else if (auto st = dyn_cast<LLVM::LLVMStructType>(memrefType.getElementType())) {
      if (st.isIdentified()) {
        os << st.getName().split("struct.").second;
      }
      else
        return emitError(loc, "ICT_ERROR(): cannot emit struct type: ") << st;
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
    auto addrspace = llvmPtrType.getAddressSpace();

    if (addrspace == 0 || addrspace == 1) {
      // os << "__gm__ ";
      if (llvmPtrType.isOpaque())
        elementType = IntegerType::get(llvmPtrType.getContext(), 8,
                                       IntegerType::Unsigned);
      else
        elementType = llvmPtrType.getElementType();
    } else if (addrspace == 6) {
      // os << "__ubuf__ ";
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

  if (auto vecType = dyn_cast<VectorType>(type)) {
    // os << "__nram__ ";
    if (failed(emitType(loc, vecType.getElementType())))
      return failure();
    os << "*";
    return success();
  }

  if (auto st = dyn_cast<LLVM::LLVMStructType>(type)) {
    if (st.isIdentified()) {
      os << st.getName().split("struct.").second;
      return success();
    }
    else
      return emitError(loc, "ICT_ERROR(): cannot emit struct type: ") << st;
  }

  if (auto arr = dyn_cast<LLVM::LLVMArrayType>(type)) {
    if (failed(emitType(loc, arr.getElementType())))
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
  os << "std::tuple<";
  if (failed(interleaveCommaWithError(
          types, os, [&](Type type) { return emitType(loc, type); })))
    return failure();
  os << ">";
  return success();
}

LogicalResult emitc::translateToCpp(Operation *op, raw_ostream &os,
                                    bool declareVariablesAtTop) {
  CppEmitter emitter(os, declareVariablesAtTop);
  return emitter.emitOperation(*op, /*trailingSemicolon=*/false);
}
