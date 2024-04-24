#ifndef LLVM_ANALYSIS_HACL_GEMMSTATEANALYSIS_H
#define LLVM_ANALYSIS_HACL_GEMMSTATEANALYSIS_H

#include "llvm/Analysis/HACL/DataFlowAnalysis.h"
#include "llvm/Analysis/HACL/BasicPointsToAnalysis.h"
#include "llvm/InitializePasses.h"

using namespace llvm;

namespace hacl {
/// Dataflow fact used in gemm state analysis.
struct GemmConfig {
  bool Valid;
  Value *GemmOutput;
  uint16_t M;
  uint16_t K;
  uint16_t N;
  Type *OutputTy;

  GemmConfig() : Valid(false) {}
  GemmConfig(Value *GemmOutput, uint16_t M, uint16_t K, uint16_t N,
             Type *OutputTy)
      : Valid(true), GemmOutput(GemmOutput), M(M), K(K), N(N),
        OutputTy(OutputTy) {}

  bool operator==(const GemmConfig &Other) {
    return Valid == Other.Valid && GemmOutput == Other.GemmOutput &&
           M == Other.M && K == Other.K && N == Other.N &&
           OutputTy == Other.OutputTy;
  }
  bool operator!=(const GemmConfig &Other) { return !(*this == Other); }
};
struct GemmStateDFValType {
  GemmConfig Config;
  std::set<Value *> AssignedObjs;

  bool operator==(const GemmStateDFValType &Other) {
    return Config == Other.Config && AssignedObjs == Other.AssignedObjs;
  }

  bool operator!=(const GemmStateDFValType &Other) { return !(*this == Other); }
};

/// Gemmm state dataflow analysis visitor.
class GemmStateDFVisitor : public DataFlowVisitor<GemmStateDFValType> {
  /// Tranfer function to be override
  virtual bool VisitInst(Instruction *Inst, GemmStateDFValType &Param) override;
  /// Merge function to be override
  virtual bool Merge(GemmStateDFValType &dst,
                     const GemmStateDFValType &src) override;

  /// Points-to Analysis result
  PointsToInfo *PTInfo;
  std::set<Instruction *> Objects;

public:
  GemmStateDFVisitor(PointsToInfo *PTInfo)
      : DataFlowVisitor<GemmStateDFValType>(), PTInfo(PTInfo) {}
  void SetObjects(std::set<Instruction *> &Objs) { Objects = Objs; }
  PointsToInfo *GetPointsToInfo() { return PTInfo; }
};

/// Gemm state dataflow analysis engine.
class GemmStateInfo : public DataFlowEngine<GemmStateDFValType> {
  GemmStateDFVisitor DFVisitor;
  PointsToInfo *PTInfo;

  void Initialize();

public:
  GemmStateInfo(Function *Func, PointsToInfo *PTInfo)
      : DataFlowEngine<GemmStateDFValType>(Func, &DFVisitor), DFVisitor(PTInfo),
        PTInfo(PTInfo) {
    Initialize();
  }
  PointsToInfo *GetPointsToInfo() { return PTInfo; }
  void print(raw_ostream &Out);
};

/// Legacy pass manager pass to compute Gemm state information in a function
class HACLGemmStateAnalysis : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLGemmStateAnalysis() : FunctionPass(ID) {
    initializeHACLGemmStateAnalysisPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  GemmStateInfo &getResult() const;

private:
  std::unique_ptr<GemmStateInfo> info;
}; // class HACLGemmStateAnalysis

} // end namespace hacl

namespace llvm {
/// createHACLGemmStateAnalysisPass - This creates an instance of the
/// HACLGemmStateAnalysis pass.
FunctionPass *createHACLGemmStateAnalysisPass();
} // namespace llvm

#endif