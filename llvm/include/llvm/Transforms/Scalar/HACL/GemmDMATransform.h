/// Insert DMA between L0C and UB according analysis result of GemmDMAAnalysis
/// pass.

#ifndef LLVM_TRANSFORMS_SCALAR_HACL_GEMMDMATRANSFORM_H
#define LLVM_TRANSFORMS_SCALAR_HACL_GEMMDMATRANSFORM_H

#include "llvm/IR/PassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

using namespace llvm;

namespace hacl {

/// A pass that insert DMA operations between L0C and UB.
class HACLGemmDMATransform : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLGemmDMATransform() : FunctionPass(ID) {
    initializeHACLGemmDMATransformPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void getAnalysisUsage(AnalysisUsage &) const override;
}; // class HACLGemmDMATransform

} // end namespace hacl

namespace llvm {
/// createHACLGemmDMATransformPass - This creates an instance of the
/// HACLGemmDMATransform pass.
FunctionPass *createHACLGemmDMATransformPass();
} // end namespace llvm

#endif