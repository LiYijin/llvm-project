#!/bin/bash
# For 910A, my intrinsic test command is:
# clang++ -I /data/lishuaijiang/workspace/31_Polygeist_newest/Polygeist/llvm-project/build/include/ main.cpp -I/data/lishuaijiang/workspace/31_Polygeist_newest/Polygeist/llvm-project/mlir/include/ -I/data/lishuaijiang/workspace/31_Polygeist_newest/Polygeist/llvm-project/build/tools/mlir/include `llvm-config --cxxflags --ldflags --system-libs --libs core` -o main

# Why do not use `llvm-config --cxxflags --ldflags --system-libs --libs core` directly?
# Because this command's result has `-lzstd`, the `ld` command will report error: `cannot find -lzstd`.
# So I using the `ls`'s result(without -lzstd) to replace the `llvm-config`'s result.
clang++ 910B3-intrinsic-test.cpp -L/usr/lib/x86_64-linux-gnu -I/root/root1/project-910B3/cvm-core/polygeist/mlir-build/include/ -I/root/root1/project-910B3/cvm-core/polygeist/llvm-project/mlir/include/ -I/root/root1/project-910B3/cvm-core/polygeist/mlir-build/tools/mlir/include -I/root/root1/project-910B3/cvm-core/polygeist/llvm-project/llvm/include -std=c++17   -fno-exceptions -funwind-tables -fno-rtti -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS \
-L/root/root1/project-910B3/cvm-core/polygeist/mlir-build/lib \
-lLLVMCore -lLLVMRemarks -lLLVMBitstreamReader -lLLVMBinaryFormat -lLLVMTargetParser -lLLVMSupport -lLLVMDemangle \
-lrt -ldl -lpthread -lm -lz -ltinfo \
-o 910B3-intrinsic-test


# The executing output is:
# root@238ba5fe0ffa ~/root1/project-910B3/cvm-core/polygeist/my-test/01-910B3-intrinsic-test$ ./910B3-intrinsic-test
# ; ModuleID = 'emit-llvm'
# source_filename = "emit-llvm"

# define void @main() {
# entry:
#   call void @llvm.hivm.mem.bar.st.ld()
#   ret void
# }

# ; Function Attrs: nounwind
# declare void @llvm.hivm.mem.bar.st.ld() #0

# attributes #0 = { nounwind }
# root@238ba5fe0ffa ~/root1/project-910B3/cvm-core/polygeist/my-test/01-910B3-intrinsic-test$