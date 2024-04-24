#ifndef LLVM_ANALYSIS_HACL_WAWANALYSIS_H
#define LLVM_ANALYSIS_HACL_WAWANALYSIS_H

#include "llvm/Analysis/HACL/ReachingDefinitionAnalysis.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {

/// Write-After-Write(WAW) analysis.
class WAWInfo {
  ReachDefinitionInfo *RDInfo;
  std::set<std::pair<Instruction *, Instruction *>> WAWPairs;

public:
  WAWInfo(ReachDefinitionInfo *RDInfo) : RDInfo(RDInfo) {}
  void CollectWAWPairs();
  std::set<std::pair<Instruction *, Instruction *>> &GetWAWPairs() {
    return WAWPairs;
  }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute Write-After-Write(WAW) information in a
/// function
class HACLWAWAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLWAWAnalysis() : FunctionPass(ID) {
    initializeHACLWAWAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  WAWInfo &getResult() const;

private:
  std::unique_ptr<WAWInfo> info;
}; // class HACLWAWAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLWAWAnalysisPass - This creates an instance of the
/// HACLWAWAnalysis pass.
FunctionPass *createHACLWAWAnalysisPass();
} // namespace llvm

#endif