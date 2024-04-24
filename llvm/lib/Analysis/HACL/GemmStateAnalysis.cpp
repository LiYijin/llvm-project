#include "llvm/Analysis/HACL/GemmStateAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLGemmStateAnalysis, "hacl-gemmstate",
                      "HACL Gemm State Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLBasicPointsToAnalysis)
INITIALIZE_PASS_END(HACLGemmStateAnalysis, "hacl-gemmstate",
                    "HACL Gemm State Analysis", false, true)

char HACLGemmStateAnalysis::ID = 0;

FunctionPass *llvm::createHACLGemmStateAnalysisPass() {
  return new HACLGemmStateAnalysis();
}

static void GetHACLGemmConfig(Instruction *Gemm, GemmConfig *Config,
                              bool *InitC, PointsToInfo *PTInfo) {
  // Get config value
  uint64_t ConfigNum = cast<ConstantInt>(Gemm->getOperand(3))->getZExtValue();
  Config->M = ConfigNum & 0xFFFF;
  ConfigNum >>= 16;
  Config->K = ConfigNum & 0xFFFF;
  ConfigNum >>= 16;
  Config->N = ConfigNum & 0xFFFF;
  ConfigNum >>= 31;
  *InitC = ConfigNum & 1;

  // Get output matrix
  Value *Output = Gemm->getOperand(0);
  auto AliasObjs = PTInfo->GetPointsToObjsOfVal(Output, Gemm);
  Config->GemmOutput = *AliasObjs.begin();
  Config->OutputTy = Gemm->getOperand(0)->getType();

  Config->Valid = true;
}

bool GemmStateDFVisitor::VisitInst(Instruction *Inst,
                                   GemmStateDFValType &Param) {

  if (Objects.find(Inst) != Objects.end()) {
    bool Ret = Param.AssignedObjs.erase(Inst);
    if (Param.Config.Valid && Param.Config.GemmOutput == Inst) {
      Param.Config.Valid = false;
      Ret = true;
    }
    return Ret;
  }

  if (IsGemmIntrinsic(Inst)) {
    bool InitC;
    GemmConfig Config;
    GetHACLGemmConfig(Inst, &Config, &InitC, PTInfo);
    Param.Config = Config;
    Param.AssignedObjs.insert(Config.GemmOutput);
    return true;
  }
  return false;
}

static bool UnionSet(std::set<Value *> &Dst, const std::set<Value *> &Src) {
  bool Ret = false;
  for (Value *Val : Src) {
    Ret |= Dst.insert(Val).second;
  }
  return Ret;
}

bool GemmStateDFVisitor::Merge(GemmStateDFValType &Dst,
                               const GemmStateDFValType &Src) {

  bool Ret = false;
  bool DstValid = Dst.Config.Valid, SrcValid = Src.Config.Valid;
  if (!DstValid && SrcValid) {
    if (Dst.AssignedObjs.find(Src.Config.GemmOutput) ==
        Dst.AssignedObjs.end()) {
      Dst.Config = Src.Config;
      Ret = true;
    }
  } else if (!SrcValid && DstValid) {
    if (Src.AssignedObjs.find(Dst.Config.GemmOutput) !=
        Src.AssignedObjs.end()) {
      Dst.Config.Valid = false;
      Ret = true;
    }
  } else if (SrcValid && DstValid) {
    if (Dst.Config != Src.Config) {
      Dst.Config.Valid = false;
      Ret = true;
    }
  }

  Ret |= UnionSet(Dst.AssignedObjs, Src.AssignedObjs);
  return Ret;
}

void GemmStateInfo::Initialize() {
  GemmStateDFValType tmp;
  InitializeEntryResult(tmp);

  std::set<Instruction *> Objs = CollectObjects(GetFunction());
  DFVisitor.SetObjects(Objs);
}

void GemmStateInfo::print(raw_ostream &Out) {
  Function *F = GetFunction();
  Out << "---------Result Of Gemm State Analysis---------\n";
  for (BasicBlock &BB : *F) {
    GemmStateDFValType DFVal = GetBBEntryResult(&BB);
    for (Instruction &Inst : BB) {
      GetVistor()->VisitInst(&Inst, DFVal);
      Out << "Inst: " << Inst << '\n';
      Out << "Assigned: \n";
      for (Value *Val : DFVal.AssignedObjs) {
        Out << *Val << '\n';
      }
      if (DFVal.Config.Valid) {
        Out << "Gemm Config: \n";
        Out << "Output matrix: " << *DFVal.Config.GemmOutput
            << ", M: " << DFVal.Config.M << ", K: " << DFVal.Config.K
            << ", N: " << DFVal.Config.N << '\n';
      } else {
        Out << "Gemm Config is invalid\n";
      }
    }
  }
}

void HACLGemmStateAnalysis::print(raw_ostream &Out,
                                  const Module *Module) const {
  info->print(Out);
}

bool HACLGemmStateAnalysis::runOnFunction(Function &F) {
  auto &PTInfo = getAnalysis<HACLBasicPointsToAnalysis>().getResult();
  GemmStateInfo *Result = new GemmStateInfo(&F, &PTInfo);
  Result->ComputeForwardDataFlow();
  info.reset(Result);
  return false;
}

GemmStateInfo &HACLGemmStateAnalysis::getResult() const { return *info; }

void HACLGemmStateAnalysis::releaseMemory() { info.reset(); }

void HACLGemmStateAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLBasicPointsToAnalysis>();
}