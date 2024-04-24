/// Insert sync instructions according to the result of dependence analysis

#ifndef LLVM_TRANSFORMS_SCALAR_HACL_SYNCINSERTTRANSFORM_H
#define LLVM_TRANSFORMS_SCALAR_HACL_SYNCINSERTTRANSFORM_H

#include "llvm/IR/PassManager.h"
#include "llvm/Analysis/HACL/RAWAnalysis.h"
#include "llvm/Analysis/HACL/WAWAnalysis.h"
#include "llvm/Analysis/HACL/WARAnalysis.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

namespace hacl {

typedef std::map<std::pair<unsigned, unsigned>, unsigned> EventIDType;
typedef std::set<std::pair<Instruction *, Instruction *>> DepType;

/// A pass that insert sync instructions according to the result of dependence
/// analysis. For one [src, dst] dependence pair, if src and dst belongs to
/// different pipeline, this pass will insert set_flag/wait_flag pair after src.
/// if src and dst belongs to the same pipeline, this pass will insert barrier
/// after src. For set_flag/wait_flag, the event_id is used rolling, when 4
/// event_id is used up, insert a reversed set_flag/wait_flag pair.
class HACLSyncInsertTransform : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLSyncInsertTransform() : FunctionPass(ID) {
    initializeHACLSyncInsertTransformPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void getAnalysisUsage(AnalysisUsage &) const override;

private:
  EventIDType
  mergeEventIDForPredecessors(BasicBlock *,
                              std::map<BasicBlock *, EventIDType> &);
  std::map<Instruction *, std::set<Instruction *>>
  collectDeps(DepType &RAW, DepType &WAR, DepType &WAW);
}; // class HACLSyncInsertTransform

} // end namespace hacl

namespace llvm {
/// createHACLSyncInsertTransformPass - This creates an instance of the
/// HACLSyncInsertTransform pass.
FunctionPass *createHACLSyncInsertTransformPass();
} // end namespace llvm

#endif