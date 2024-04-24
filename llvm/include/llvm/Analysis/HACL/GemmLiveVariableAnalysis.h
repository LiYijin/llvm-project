#ifndef LLVM_ANALYSIS_HACL_GEMMLIVEVARIABLEANALYSIS_H
#define LLVM_ANALYSIS_HACL_GEMMLIVEVARIABLEANALYSIS_H

#include "llvm/Analysis/HACL/DataFlowAnalysis.h"
#include "llvm/Analysis/HACL/BasicPointsToAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in gemm live variable analysis.
typedef std::set<Value *> GemmLiveVarDFValType;

/// Live variable dataflow analysis visitor.
class GemmLiveVariableDFVisitor : public DataFlowVisitor<GemmLiveVarDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst,
                         GemmLiveVarDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(GemmLiveVarDFValType &dst,
                     const GemmLiveVarDFValType &src) override;

  /// Points-to Analysis result
  PointsToInfo *PTInfo;
  /// LoopInfo
  LoopInfo *LI;
  /// ScalarEvolution result
  ScalarEvolution *SE;
  std::set<Instruction *> Objects;

public:
  GemmLiveVariableDFVisitor(PointsToInfo *PTInfo, LoopInfo *LI,
                            ScalarEvolution *SE)
      : DataFlowVisitor<GemmLiveVarDFValType>(), PTInfo(PTInfo), LI(LI),
        SE(SE) {}
  void SetObjects(std::set<Instruction *> &Objs) { Objects = Objs; }
};

/// Gemm live variable dataflow analysis engine.
class GemmLiveVariableInfo : public DataFlowEngine<GemmLiveVarDFValType> {
  GemmLiveVariableDFVisitor DFVisitor;

  void Initialize();

public:
  GemmLiveVariableInfo(Function *Func, PointsToInfo *PTInfo, LoopInfo *LI,
                       ScalarEvolution *SE)
      : DataFlowEngine<GemmLiveVarDFValType>(Func, &DFVisitor),
        DFVisitor(PTInfo, LI, SE) {
    Initialize();
  }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute gemm live variable information in a
/// function
class HACLGemmLiveVariableAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLGemmLiveVariableAnalysis() : FunctionPass(ID) {
    initializeHACLGemmLiveVariableAnalysisPass(
        *PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  GemmLiveVariableInfo &getResult() const;

private:
  std::unique_ptr<GemmLiveVariableInfo> info;
}; // class HACLGemmLiveVariableAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLGemmLiveVariableAnalysisPass - This creates an instance of the
/// HACLGemmLiveVariableAnalysis pass.
FunctionPass *createHACLGemmLiveVariableAnalysisPass();
} // namespace llvm

#endif