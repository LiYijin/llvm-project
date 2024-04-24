#include "llvm/Analysis/HACL/RAWAnalysis.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLRAWAnalysis, "hacl-raw",
                      "HACL Read-after-write Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLReachDefinitionAnalysis)
INITIALIZE_PASS_END(HACLRAWAnalysis, "hacl-raw",
                    "HACL Read-after-write Analysis", false, true)

char HACLRAWAnalysis::ID = 0;

FunctionPass *llvm::createHACLRAWAnalysisPass() {
  return new HACLRAWAnalysis();
}

bool RAWDFVisitor::VisitInst(Instruction *Inst, RAWDFValType &Param) {
  bool Ret = false;
  ReachDefDFValType ReachDefs = RDInfo->GetInstResult(Inst, true);

  pipe_t Pipe = GetPipeType(Inst);
  if (LoadInst *LdInst = dyn_cast<LoadInst>(Inst)) {
    Value *Pointer = LdInst->getPointerOperand();
    auto AliasObjs = PTInfo->GetOverlappedPointsToObjsOfVal(Pointer, Inst);
    for (Value *Obj : AliasObjs) {
      for (Instruction *Def : ReachDefs.ReachDefs[Obj]) {
        Ret |= Param.RAWDFVal.erase(std::make_pair(Def, Pipe));
      }
    }
  } else if (StoreInst *StInst = dyn_cast<StoreInst>(Inst)) {
    auto AliasObjs = PTInfo->GetOverlappedPointsToObjsOfVal(
        StInst->getPointerOperand(), Inst);
    if (!AliasObjs.empty()) {
      for (unsigned i = 0; i < 6; ++i) {
        Ret |= Param.RAWDFVal.insert(std::make_pair(Inst, i)).second;
      }
    }
  } else if (IsHIVMIntrinsic(Inst)) {
    CallInst *Call = dyn_cast<CallInst>(Inst);
    StringRef Callee = Call->getCalledFunction()->getName();
    std::set<Value *> Ptrs;
    if (Callee == "llvm.hivm.GET.IMM.16") {
      return false;
    } else if (Callee == "llvm.hivm.MOVEVA") {
      return GetVAStatus(Call, &Param.VA);
    } else if (Callee.startswith("llvm.hivm.S.VNCHWCONV")) {
      // Get src object
      for (Value *Src : Param.VA.Srcs) {
        auto Pointers = PTInfo->GetOverlappedPointsToObjsOfVal(Src, Inst);
        Ptrs.insert(Pointers.begin(), Pointers.end());
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
    std::set<Value *> AliasObjs;
    for (Value *Pointer : Ptrs) {
      auto Objs = PTInfo->GetOverlappedPointsToObjsOfVal(Pointer, Inst);
      AliasObjs.insert(Objs.begin(), Objs.end());
    }
    for (Value *Obj : AliasObjs) {
      for (Instruction *Def : ReachDefs.ReachDefs[Obj]) {
        Ret |= Param.RAWDFVal.erase(std::make_pair(Def, Pipe));
      }
    }
    // Add dst object to dataflow fact
    for (unsigned i = 0; i < 6; ++i) {
      Ret |= Param.RAWDFVal.insert(std::make_pair(Inst, i)).second;
    }
  }
  return Ret;
}

bool RAWDFVisitor::Merge(RAWDFValType &Dst, const RAWDFValType &Src) {
  bool Ret = false;
  for (auto it = Src.RAWDFVal.begin(), ie = Src.RAWDFVal.end(); it != ie;
       ++it) {
    Ret |= Dst.RAWDFVal.insert(*it).second;
  }
  for (auto it = Src.VA.Srcs.begin(), ie = Src.VA.Srcs.end(); it != ie; ++it) {
    Ret |= Dst.VA.Srcs.insert(*it).second;
  }
  for (auto it = Src.VA.Dsts.begin(), ie = Src.VA.Dsts.end(); it != ie; ++it) {
    Ret |= Dst.VA.Dsts.insert(*it).second;
  }
  return Ret;
}

void RAWInfo::Initialize() {
  RAWDFValType tmp;
  InitializeExitResult(tmp);
}

void RAWInfo::CollectRAWPairs() {
  Function *F = GetFunction();
  RAWDFValType DFValPrev;
  for (Instruction &Inst : instructions(F)) {
    pipe_t PipeDst = GetPipeType(&Inst);
    if (&Inst == &(Inst.getParent()->front())) {
      DFValPrev = GetInstResult(&Inst, true);
    }
    RAWDFValType DFValAfter = DFValPrev;
    GetVistor()->VisitInst(&Inst, DFValAfter);

    for (auto it = DFValPrev.RAWDFVal.begin(), ie = DFValPrev.RAWDFVal.end();
         it != ie; ++it) {
      if (DFValAfter.RAWDFVal.find(*it) == DFValAfter.RAWDFVal.end()) {
        pipe_t PipeSrc = GetPipeType(it->first);
        if (PipeSrc == PIPE_S && PipeDst == PIPE_S)
          continue;
        RAWPairs.insert(std::make_pair(it->first, &Inst));
      }
    }
    DFValPrev = DFValAfter;
  }
}

void RAWInfo::print(raw_ostream &Out) {
  Out << "---------Result Of Read-after-write Analysis---------\n";
  for (auto it = RAWPairs.begin(), ie = RAWPairs.end(); it != ie; ++it) {
    llvm::errs() << "Src: " << *(it->first) << ", Dst: " << *(it->second)
                 << '\n';
  }
}

void HACLRAWAnalysis::print(raw_ostream &Out, const Module *Module) const {
  info->print(Out);
}

bool HACLRAWAnalysis::runOnFunction(Function &F) {
  auto &PTInfo = getAnalysis<HACLBasicPointsToAnalysis>().getResult();
  auto &RDInfo = getAnalysis<HACLReachDefinitionAnalysis>().getResult();
  RAWInfo *Result = new RAWInfo(&F, &PTInfo, &RDInfo);
  Result->ComputeForwardDataFlow();
  Result->CollectRAWPairs();
  info.reset(Result);
  return false;
}

RAWInfo &HACLRAWAnalysis::getResult() const { return *info; }

void HACLRAWAnalysis::releaseMemory() { info.reset(); }

void HACLRAWAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLBasicPointsToAnalysis>();
  AU.addRequiredTransitive<HACLReachDefinitionAnalysis>();
}