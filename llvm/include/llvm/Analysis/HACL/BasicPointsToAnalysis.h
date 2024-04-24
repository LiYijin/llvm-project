#ifndef LLVM_ANALYSIS_HACL_POINTSTOANALYSIS_H
#define LLVM_ANALYSIS_HACL_POINTSTOANALYSIS_H

/// Flow-sensitive points-to analysis for HACL.
/// This pass will compute points-to information by dataflow analysis.
/// For each program point, it will give objects which the pointer may point
/// to.

#include <set>
#include "llvm/Analysis/HACL/DataFlowAnalysis.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in points-to analysis.
typedef std::map<Value *, std::set<Value *>> PointsToDFValType;

/// Points-to analysis visitor.
class PointsToDFVisitor : public DataFlowVisitor<PointsToDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst, PointsToDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(PointsToDFValType &dst,
                     const PointsToDFValType &src) override;

public:
  PointsToDFVisitor() : DataFlowVisitor<PointsToDFValType>() {}
};

/// Points-to dataflow analysis engine.
class PointsToInfo : public DataFlowEngine<PointsToDFValType> {
  PointsToDFVisitor DFVisitor;
  std::map<Value *, std::set<Value *>> OverlappedObjs;

  void Initialize();
  void CollectBaseObjAliasInfo();

public:
  PointsToInfo(Function *Func)
      : DataFlowEngine<PointsToDFValType>(Func, &DFVisitor), DFVisitor() {
    Initialize();
  }
  /// Get points-to analysis result.
  std::set<Value *> GetPointsToObjsOfVal(Value *Val, Instruction *Pos);
  /// Get points-to analysis result including overlapped objects.
  std::set<Value *> GetOverlappedPointsToObjsOfVal(Value *Val,
                                                   Instruction *Pos);
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute points-to information in a function
class HACLBasicPointsToAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLBasicPointsToAnalysis() : FunctionPass(ID) {
    initializeHACLBasicPointsToAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  PointsToInfo &getResult() const;

private:
  std::unique_ptr<PointsToInfo> info;
}; // class HACLBasicPointsToAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLBasicPointsToAnalysisPass - This creates an instance of the
/// HACLBasicPointsToAnalysis pass.
FunctionPass *createHACLBasicPointsToAnalysisPass();
} // namespace llvm

#endif