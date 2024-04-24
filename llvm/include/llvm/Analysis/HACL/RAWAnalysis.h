#ifndef LLVM_ANALYSIS_HACL_RAWANALYSIS_H
#define LLVM_ANALYSIS_HACL_RAWANALYSIS_H

#include "llvm/Analysis/HACL/ReachingDefinitionAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in Read-After-Write(RAW) dependence analysis.
typedef struct {
  std::set<std::pair<Instruction *, unsigned>> RAWDFVal;
  VAStatus VA; // Vec_trans_scatter status
} RAWDFValType;

/// Read-After-Write(RAW) dataflow analysis visitor.
class RAWDFVisitor : public DataFlowVisitor<RAWDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst, RAWDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(RAWDFValType &dst, const RAWDFValType &src) override;

  /// Points-to Analysis result
  PointsToInfo *PTInfo;
  /// Reaching Definition result
  ReachDefinitionInfo *RDInfo;

public:
  RAWDFVisitor(PointsToInfo *PTInfo, ReachDefinitionInfo *RDInfo)
      : DataFlowVisitor<RAWDFValType>(), PTInfo(PTInfo), RDInfo(RDInfo) {}
};

/// Read-After-Write(RAW) dataflow analysis engine.
class RAWInfo : public DataFlowEngine<RAWDFValType> {
  RAWDFVisitor DFVisitor;
  std::set<std::pair<Instruction *, Instruction *>> RAWPairs;

  void Initialize();

public:
  RAWInfo(Function *Func, PointsToInfo *PTInfo, ReachDefinitionInfo *RDInfo)
      : DataFlowEngine<RAWDFValType>(Func, &DFVisitor),
        DFVisitor(PTInfo, RDInfo) {
    Initialize();
  }
  void CollectRAWPairs();
  std::set<std::pair<Instruction *, Instruction *>> &GetRAWPairs() {
    return RAWPairs;
  }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute Read-After-Write(RAW) information in a
/// function
class HACLRAWAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLRAWAnalysis() : FunctionPass(ID) {
    initializeHACLRAWAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  RAWInfo &getResult() const;

private:
  std::unique_ptr<RAWInfo> info;
}; // class HACLRAWAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLRAWAnalysisPass - This creates an instance of the
/// HACLRAWAnalysis pass.
FunctionPass *createHACLRAWAnalysisPass();
} // namespace llvm

#endif