#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IntrinsicsHivm.h"
#include <iostream>

using namespace llvm;

int main() {
  LLVMContext context;
  Module Module("emit-llvm", context);
  IRBuilder<> Builder(context);
  FunctionType *FuncType = FunctionType::get(Type::getVoidTy(context), false);
  Function *MainFunc = Function::Create(FuncType, Function::ExternalLinkage,
                                        "main", &Module);
  BasicBlock *EntryBlock = BasicBlock::Create(context, "entry", MainFunc);
  Builder.SetInsertPoint(EntryBlock);
  Function *fn =
      llvm::Intrinsic::getDeclaration(&Module, llvm::Intrinsic::hivm_mem_bar_st_ld);
  auto *inst = Builder.CreateCall(fn);
  // Emit LLVM IR instructions
  Builder.CreateRetVoid();
  // Print LLVM IR
  Module.print(outs(), nullptr);
  return 0;
}