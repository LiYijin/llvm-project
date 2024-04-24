/// Insert dedicated loop exit block.

#ifndef LLVM_TRANSFORMS_SCALAR_HACL_LOOPDEDICATEDEXITINSERTING_H
#define LLVM_TRANSFORMS_SCALAR_HACL_LOOPDEDICATEDEXITINSERTING_H

#include "llvm/IR/PassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

using namespace llvm;

namespace hacl {

/// A pass that insert dedicated exit block for loop.
class LoopDedicatedExitInserting : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  LoopDedicatedExitInserting() : FunctionPass(ID) {
    initializeLoopDedicatedExitInsertingPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void getAnalysisUsage(AnalysisUsage &) const override;
}; // class LoopDedicatedExitInserting

} // end namespace hacl

namespace llvm {
/// createLoopDedicatedExitInsertingPass - This creates an instance of the
/// LoopDedicatedExitInserting pass.
FunctionPass *createLoopDedicatedExitInsertingPass();
} // end namespace llvm

#endif
