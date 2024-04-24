#include "llvm/Analysis/HACL/LiveVariableAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLLiveVariableAnalysis, "hacl-livevar",
                      "HACL Live Variable Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLBasicPointsToAnalysis)
INITIALIZE_PASS_END(HACLLiveVariableAnalysis, "hacl-livevar",
                    "HACL Live Variable Analysis", false, true)

char HACLLiveVariableAnalysis::ID = 0;

FunctionPass *llvm::createHACLLiveVariableAnalysisPass() {
  return new HACLLiveVariableAnalysis();
}

bool LiveVariableDFVisitor::VisitInst(Instruction *Inst,
                                      LiveVarDFValType &Param) {
  bool Ret = false;

  if (Objects.find(Inst) != Objects.end())
    return Param.erase(Inst);

  std::set<Value *> Ptrs;
  if (LoadInst *LdInst = dyn_cast<LoadInst>(Inst)) {
    Ptrs.insert(LdInst->getPointerOperand());
  } else if (IsHIVMIntrinsic(Inst)) {
    CallInst *Call = dyn_cast<CallInst>(Inst);
    StringRef Callee = Call->getCalledFunction()->getName();
    if (Callee == "llvm.hivm.GET.ADDR") {
      return false;
    } else if (Callee.startswith("llvm.hivm.S.VNCHWCONV")) {
      // Get src object
      BasicBlock::reverse_iterator IT(Inst);
      VAStatus VA;
      for (; IT != Inst->getParent()->rend(); ++IT) {
        if (CallInst *Call = dyn_cast<CallInst>(&*IT)) {
          GetVAStatus(Call, &VA);
          if (!VA.Srcs.empty()) {
            auto Pointers =
                PTInfo->GetPointsToObjsOfVal(*VA.Srcs.begin(), Inst);
            Ptrs.insert(Pointers.begin(), Pointers.end());
            break;
          }
        }
      }
    } else {
      unsigned i = 1, n = Call->arg_size();
      if (Callee == "llvm.hivm.SET.CMPMASK")
        i = 0;
      for (; i < n; ++i) {
        Value *Arg = Call->getArgOperand(i);
        if (!Arg->getType()->isPointerTy())
          continue;
        Ptrs.insert(Arg);
      }
    }
  }
  for (Value *Pointer : Ptrs) {
    auto AliasObjs = PTInfo->GetPointsToObjsOfVal(Pointer, Inst);
    for (Value *Obj : AliasObjs) {
      if (Obj->getType()->getPointerAddressSpace() != 1) {
        Ret |= Param.insert(dyn_cast<Instruction>(Obj)).second;
      }
    }
  }
  return Ret;
}

bool LiveVariableDFVisitor::Merge(LiveVarDFValType &Dst,
                                  const LiveVarDFValType &Src) {
  bool Ret = false;
  for (auto it = Src.begin(), ie = Src.end(); it != ie; ++it) {
    Ret |= Dst.insert(*it).second;
  }
  return Ret;
}

void LiveVariableInfo::Initialize() {
  LiveVarDFValType tmp;
  InitializeExitResult(tmp);

  std::set<Instruction *> Objs = CollectObjects(GetFunction());
  DFVisitor.SetObjects(Objs);
}

void LiveVariableInfo::print(raw_ostream &Out) {
  Function *F = GetFunction();
  Out << "---------Result Of Live Variable Analysis---------\n";
  for (Instruction &Inst : instructions(F)) {
    LiveVarDFValType DFVal = GetInstResult(&Inst, false);
    Out << "Inst: " << Inst << '\n';
    for (auto it = DFVal.begin(), ie = DFVal.end(); it != ie; ++it) {
      Out << **it << '\n';
    }
  }
}

void HACLLiveVariableAnalysis::print(raw_ostream &Out,
                                     const Module *Module) const {
  info->print(Out);
}

bool HACLLiveVariableAnalysis::runOnFunction(Function &F) {
  auto &PTInfo = getAnalysis<HACLBasicPointsToAnalysis>().getResult();
  LiveVariableInfo *Result = new LiveVariableInfo(&F, &PTInfo);
  Result->ComputeBackwardDataFlow();
  info.reset(Result);
  return false;
}

LiveVariableInfo &HACLLiveVariableAnalysis::getResult() const { return *info; }

void HACLLiveVariableAnalysis::releaseMemory() { info.reset(); }

void HACLLiveVariableAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLBasicPointsToAnalysis>();
}