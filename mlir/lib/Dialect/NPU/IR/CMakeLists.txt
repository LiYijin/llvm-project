add_mlir_dialect_library(MLIRINNPU
  NPUDialect.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/NPU

  # DEPENDS
  # MLIRNPUIncGen

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRSupport
  MLIRLLVMDialect
  MLIRSideEffectInterfaces
  )