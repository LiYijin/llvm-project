set(LLVM_TARGET_DEFINITIONS NPU.td)
mlir_tablegen(NPUEnums.h.inc -gen-enum-decls)
mlir_tablegen(NPUEnums.cpp.inc -gen-enum-defs)
mlir_tablegen(NPUAttributes.h.inc -gen-attrdef-decls
              -attrdefs-dialect=npu)
mlir_tablegen(NPUAttributes.cpp.inc -gen-attrdef-defs
              -attrdefs-dialect=npu)
add_mlir_dialect(NPU npu)