/// Live Interval analysis used in on-chip memory allocation.

#ifndef LLVM_ANALYSIS_HACL_LIVEINTERVALANALYSIS_H
#define LLVM_ANALYSIS_HACL_LIVEINTERVALANALYSIS_H

#include "llvm/Analysis/HACL/LiveVariableAnalysis.h"
#include "llvm/Analysis/HACL/ReachingDefinitionAnalysis.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {

typedef std::pair<unsigned, unsigned> Interval;

/// IntervalInfo - This class is the main live interval analysis driver.
class IntervalInfo {
public:
  IntervalInfo(Function *F, LiveVariableInfo *LV, ReachDefinitionInfo *RD)
      : LV(LV), RD(RD), F(F) {
    ComputeIntervals();
  }
  /// Get live interval result
  std::map<Instruction *, Interval> &GetResult() { return IntervalOfVals; }
  void print(raw_ostream &);

private:
  void ComputeIntervals();

  LiveVariableInfo *LV;
  ReachDefinitionInfo *RD;
  Function *F;
  std::map<Instruction *, Interval> IntervalOfVals;
};

/// Legacy pass manager pass to compute live interval information
class HACLLiveIntervalAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLLiveIntervalAnalysis() : FunctionPass(ID) {
    initializeHACLLiveIntervalAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  IntervalInfo &getResult() const;

private:
  std::unique_ptr<IntervalInfo> info;
}; // class HACLLiveIntervalAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLLiveIntervalAnalysisPass - This creates an instance of the
/// HACLLiveIntervalAnalysis pass.
FunctionPass *createHACLLiveIntervalAnalysisPass();
} // namespace llvm

#endif