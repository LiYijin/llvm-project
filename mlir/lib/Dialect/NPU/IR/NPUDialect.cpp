#include "mlir/Dialect/NPU/IR/NPUDialect.h"
#include "mlir/IR/DialectImplementation.h"

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Matchers.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Interfaces/ViewLikeInterface.h"
#include "llvm/Support/CommandLine.h"

using namespace mlir;
using namespace mlir::npu;

// Get NPU dialect implementation.
#include "mlir/Dialect/NPU/IR/NPUDialect.cpp.inc"

// Dialect initialization, get NPU ops list.
void NPUDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/NPU/IR/NPU.cpp.inc"
      >();
}

// Get NPU ops classes implementation.
#define GET_OP_CLASSES
#include "mlir/Dialect/NPU/IR/NPU.cpp.inc"

//===----------------------------------------------------------------------===//
// VAddF32Op
//===----------------------------------------------------------------------===//

void VAddF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value lhs, Value rhs, IntegerAttr numElements) {
  auto resType = lhs.getType();
  VAddF32Op::build(builder, state, resType, lhs, rhs, numElements);
}

//===----------------------------------------------------------------------===//
// VSubF32Op
//===----------------------------------------------------------------------===//
void VSubF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value lhs, Value rhs, IntegerAttr numElements) {
  auto resType = lhs.getType();
  VSubF32Op::build(builder, state, resType, lhs, rhs, numElements);
}

//===----------------------------------------------------------------------===//
// VMulF32Op
//===----------------------------------------------------------------------===//

void VMulF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value lhs, Value rhs, IntegerAttr numElements) {
  auto resType = lhs.getType();
  VMulF32Op::build(builder, state, resType, lhs, rhs, numElements);
}

//===----------------------------------------------------------------------===//
// VDivF32Op
//===----------------------------------------------------------------------===//

void VDivF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value lhs, Value rhs, IntegerAttr numElements) {
  auto resType = lhs.getType();
  VDivF32Op::build(builder, state, resType, lhs, rhs, numElements);
}

LogicalResult VDivF32Op::canonicalize(VDivF32Op divOp, PatternRewriter &rewriter) {
  auto lhs = divOp.getLhs();
  auto rhs = divOp.getRhs();
  auto numElems = divOp.getNumElemsAttr();

  Value recip = rewriter.create<VRecipF32Op>(divOp.getLoc(), rhs, numElems);
  rewriter.replaceOpWithNewOp<VMulF32Op>(divOp, lhs, recip, numElems);
  return success();
}

//===----------------------------------------------------------------------===//
// VRecipF32Op
//===----------------------------------------------------------------------===//

void VRecipF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                        Value operand, IntegerAttr numElements) {
  auto resType = operand.getType();
  VRecipF32Op::build(builder, state, resType, operand, numElements);
}

//===----------------------------------------------------------------------===//
// VExpF32Op
//===----------------------------------------------------------------------===//

void VExpF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value operand, IntegerAttr numElements) {
  auto resType = operand.getType();
  VExpF32Op::build(builder, state, resType, operand, numElements);
}

//===----------------------------------------------------------------------===//
// VRsqrtF32Op
//===----------------------------------------------------------------------===//

void VRsqrtF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value operand, IntegerAttr numElements) {
  auto resType = operand.getType();
  VRsqrtF32Op::build(builder, state, resType, operand, numElements);
}

//===----------------------------------------------------------------------===//
// VSqrtF32Op
//===----------------------------------------------------------------------===//

void VSqrtF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value operand, IntegerAttr numElements) {
  auto resType = operand.getType();
  VSqrtF32Op::build(builder, state, resType, operand, numElements);
}

//===----------------------------------------------------------------------===//
// SSQRTF32Op
//===----------------------------------------------------------------------===//

void SSQRTF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value operand) {
  auto resType = operand.getType();
  SSQRTF32Op::build(builder, state, resType, operand);
}

void VMaxF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value lhs, Value rhs, IntegerAttr numElements) {
  auto resType = lhs.getType();
  VMaxF32Op::build(builder, state, resType, lhs, rhs, numElements);
}

void VAddSF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value lhs, Value rhs, IntegerAttr numElements) {
  auto resType = lhs.getType();
  VAddSF32Op::build(builder, state, resType, lhs, rhs, numElements);
}

//===----------------------------------------------------------------------===//
// VTanhF32Op
//===----------------------------------------------------------------------===//

void VTanhF32Op::build(mlir::OpBuilder &builder, mlir::OperationState &state,
                      Value operand, IntegerAttr numElements) {
  auto resType = operand.getType();
  VTanhF32Op::build(builder, state, resType, operand, numElements);
}