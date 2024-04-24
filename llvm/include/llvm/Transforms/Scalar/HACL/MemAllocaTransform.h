/// Rewrite LLVM IR according to the result of memory allocation

#ifndef LLVM_TRANSFORMS_SCALAR_HACL_MEMALLOCATRANSFORM_H
#define LLVM_TRANSFORMS_SCALAR_HACL_MEMALLOCATRANSFORM_H

#include "llvm/IR/PassManager.h"
#include "llvm/Analysis/HACL/MemoryAllocation.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

namespace hacl {

/// A pass that rewrite IR according to the result of memory allocation.
/// This pass will change the addrspace of Vector/Matrix objects,
/// set address to immediate value,
/// and change intrinsics corresponding to the addrspace of arguments.
class HACLMemAllocaTransform : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLMemAllocaTransform() : FunctionPass(ID) {
    initializeHACLMemAllocaTransformPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void getAnalysisUsage(AnalysisUsage &) const override;

private:
  Instruction *transformInst(Instruction *Inst);
  void RemoveUnusedObject(Instruction *Inst);
}; // class HACLMemAllocaTransform

} // end namespace hacl

namespace llvm {
/// createHACLMemAllocaTransformPass - This creates an instance of the
/// HACLMemAllocaTransform pass.
FunctionPass *createHACLMemAllocaTransformPass();
} // end namespace llvm

#endif
