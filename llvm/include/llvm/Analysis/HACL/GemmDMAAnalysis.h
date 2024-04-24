/// Analysis when to transfer data between L0C and UB.

#ifndef LLVM_ANALYSIS_HACL_GEMMDMAANALYSIS_H
#define LLVM_ANALYSIS_HACL_GEMMDMAANALYSIS_H

#include "llvm/Analysis/HACL/GemmStateAnalysis.h"
#include "llvm/Analysis/HACL/GemmLiveVariableAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {

struct DMAAnalysisRes {
  std::map<Instruction *, GemmConfig> Stores;
  std::map<Instruction *, GemmConfig> Loads;
};

/// GemmDMAInfo - This class is the main gemm dma analysis driver.
class GemmDMAInfo {
public:
  GemmDMAInfo(Function *F, GemmStateInfo *State, GemmLiveVariableInfo *LV,
              LoopInfo *LI, DominatorTree *DT)
      : State(State), LV(LV), LI(LI), DT(DT), F(F) {
    DoGemmDMAAnalysis();
  }
  /// Get gemm dma analysis result
  DMAAnalysisRes &GetResult() { return Res; }
  void print(raw_ostream &);

private:
  void DoGemmDMAAnalysis();
  Loop *GetOutestLoopForDMA(Instruction *Inst, bool *WriteUB);
  void CheckReadOrWriteUBObject(Instruction *Inst, Value *UBObj, bool *Read,
                                bool *Write);
  bool HasWriteUBOperationInLoop(Loop *L, Value *OutputMatrix);

  GemmStateInfo *State;
  GemmLiveVariableInfo *LV;
  LoopInfo *LI;
  DominatorTree *DT;
  Function *F;
  DMAAnalysisRes Res;
};

/// Legacy pass manager pass to compute gemm dma information
class HACLGemmDMAAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLGemmDMAAnalysis() : FunctionPass(ID) {
    initializeHACLGemmDMAAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  GemmDMAInfo &getResult() const;

private:
  std::unique_ptr<GemmDMAInfo> info;
}; // class HACLGemmDMAAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLGemmDMAAnalysisPass - This creates an instance of the
/// HACLGemmDMAAnalysis pass.
FunctionPass *createHACLGemmDMAAnalysisPass();
} // namespace llvm

#endif