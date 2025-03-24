#ifndef NPU_NPUDIALECT_H
#define NPU_NPUDIALECT_H

#include "mlir/IR/Dialect.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Support/TypeID.h"
#include "mlir/IR/Region.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"

// Get NPU dialect declaration.
#include "mlir/Dialect/NPU/IR/NPUDialect.h.inc"

//===----------------------------------------------------------------------===//
// NPU Dialect Enum Attributes
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/NPU/IR/NPUEnums.h.inc"
#define GET_ATTRDEF_CLASSES
#include "mlir/Dialect/NPU/IR/NPUAttributes.h.inc"

// Get NPU Ops classes declaration.
#define GET_OP_CLASSES
#include "mlir/Dialect/NPU/IR/NPU.h.inc"

#endif // NPU_NPUDIALECT_H