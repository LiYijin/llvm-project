#ifndef LLVM_ANALYSIS_HACL_LIVEVARIABLEANALYSIS_H
#define LLVM_ANALYSIS_HACL_LIVEVARIABLEANALYSIS_H

#include "llvm/Analysis/HACL/DataFlowAnalysis.h"
#include "llvm/Analysis/HACL/BasicPointsToAnalysis.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in live variable analysis.
typedef std::set<Instruction *> LiveVarDFValType;

/// Live variable dataflow analysis visitor.
class LiveVariableDFVisitor : public DataFlowVisitor<LiveVarDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst, LiveVarDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(LiveVarDFValType &dst,
                     const LiveVarDFValType &src) override;

  /// Points-to Analysis result
  PointsToInfo *PTInfo;
  std::set<Instruction *> Objects;

public:
  LiveVariableDFVisitor(PointsToInfo *PTInfo)
      : DataFlowVisitor<LiveVarDFValType>(), PTInfo(PTInfo) {}
  void SetObjects(std::set<Instruction *> &Objs) { Objects = Objs; }
};

/// Live variable dataflow analysis engine.
class LiveVariableInfo : public DataFlowEngine<LiveVarDFValType> {
  LiveVariableDFVisitor DFVisitor;

  void Initialize();

public:
  LiveVariableInfo(Function *Func, PointsToInfo *PTInfo)
      : DataFlowEngine<LiveVarDFValType>(Func, &DFVisitor), DFVisitor(PTInfo) {
    Initialize();
  }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute live variable information in a function
class HACLLiveVariableAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLLiveVariableAnalysis() : FunctionPass(ID) {
    initializeHACLLiveVariableAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  LiveVariableInfo &getResult() const;

private:
  std::unique_ptr<LiveVariableInfo> info;
}; // class HACLLiveVariableAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLLiveVariableAnalysisPass - This creates an instance of the
/// HACLLiveVariableAnalysis pass.
FunctionPass *createHACLLiveVariableAnalysisPass();
} // namespace llvm

#endif