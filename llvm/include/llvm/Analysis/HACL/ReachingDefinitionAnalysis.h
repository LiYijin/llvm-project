#ifndef LLVM_ANALYSIS_HACL_REACHINGDEFINITIONANALYSIS_H
#define LLVM_ANALYSIS_HACL_REACHINGDEFINITIONANALYSIS_H

#include "llvm/Analysis/HACL/DataFlowAnalysis.h"
#include "llvm/Analysis/HACL/BasicPointsToAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in reaching definition analysis.
typedef struct {
  std::map<Value *, std::set<Instruction *>> ReachDefs;
  VAStatus VA; // Vec_trans_scatter status
} ReachDefDFValType;

/// Reaching definition dataflow analysis visitor.
class ReachingDefDFVisitor : public DataFlowVisitor<ReachDefDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst, ReachDefDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(ReachDefDFValType &dst,
                     const ReachDefDFValType &src) override;

  /// Points-to Analysis result
  PointsToInfo *PTInfo;

public:
  ReachingDefDFVisitor(PointsToInfo *PTInfo)
      : DataFlowVisitor<ReachDefDFValType>(), PTInfo(PTInfo) {}
};

/// Reaching definition dataflow analysis engine.
class ReachDefinitionInfo : public DataFlowEngine<ReachDefDFValType> {
  ReachingDefDFVisitor DFVisitor;

  void Initialize();

public:
  ReachDefinitionInfo(Function *Func, PointsToInfo *PTInfo)
      : DataFlowEngine<ReachDefDFValType>(Func, &DFVisitor), DFVisitor(PTInfo) {
    Initialize();
  }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute reaching definition information in a
/// function
class HACLReachDefinitionAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLReachDefinitionAnalysis() : FunctionPass(ID) {
    initializeHACLReachDefinitionAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  ReachDefinitionInfo &getResult() const;

private:
  std::unique_ptr<ReachDefinitionInfo> info;
}; // class HACLReachDefinitionAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLReachDefinitionAnalysisPass - This creates an instance of the
/// HACLReachDefinitionAnalysis pass.
FunctionPass *createHACLReachDefinitionAnalysisPass();
} // namespace llvm

#endif