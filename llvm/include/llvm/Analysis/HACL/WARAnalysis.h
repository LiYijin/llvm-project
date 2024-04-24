#ifndef LLVM_ANALYSIS_HACL_WARANALYSIS_H
#define LLVM_ANALYSIS_HACL_WARANALYSIS_H

#include "llvm/Analysis/HACL/ReachingDefinitionAnalysis.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in Write-After-Read(WAR) dependence analysis.
typedef struct {
  std::map<Instruction *, std::set<std::pair<unsigned, Instruction *>>>
      WARDFVal;
  VAStatus VA; // Vec_trans_scatter status
} WARDFValType;

/// Write-After-Read(WAR) dataflow analysis visitor.
class WARDFVisitor : public DataFlowVisitor<WARDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst, WARDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(WARDFValType &dst, const WARDFValType &src) override;

  /// Points-to Analysis result
  PointsToInfo *PTInfo;
  /// Reaching Definition result
  ReachDefinitionInfo *RDInfo;

public:
  WARDFVisitor(PointsToInfo *PTInfo, ReachDefinitionInfo *RDInfo)
      : DataFlowVisitor<WARDFValType>(), PTInfo(PTInfo), RDInfo(RDInfo) {}
};

/// Write-After-Read(WAR) dataflow analysis engine.
class WARInfo : public DataFlowEngine<WARDFValType> {
  WARDFVisitor DFVisitor;
  std::set<std::pair<Instruction *, Instruction *>> WARPairs;

  void Initialize();

public:
  WARInfo(Function *Func, PointsToInfo *PTInfo, ReachDefinitionInfo *RDInfo)
      : DataFlowEngine<WARDFValType>(Func, &DFVisitor),
        DFVisitor(PTInfo, RDInfo) {
    Initialize();
  }
  void CollectWARPairs();
  std::set<std::pair<Instruction *, Instruction *>> &GetWARPairs() {
    return WARPairs;
  }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute Write-After-Read(WAR) information in a
/// function
class HACLWARAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLWARAnalysis() : FunctionPass(ID) {
    initializeHACLWARAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  WARInfo &getResult() const;

private:
  std::unique_ptr<WARInfo> info;
}; // class HACLWARAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLWARAnalysisPass - This creates an instance of the
/// HACLWARAnalysis pass.
FunctionPass *createHACLWARAnalysisPass();
} // namespace llvm

#endif