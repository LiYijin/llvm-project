#include "llvm/Analysis/HACL/WARAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLWARAnalysis, "hacl-war",
                      "HACL Write-after-read Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLReachDefinitionAnalysis)
INITIALIZE_PASS_END(HACLWARAnalysis, "hacl-war",
                    "HACL Write-after-read Analysis", false, true)

char HACLWARAnalysis::ID = 0;

FunctionPass *llvm::createHACLWARAnalysisPass() {
  return new HACLWARAnalysis();
}

bool WARDFVisitor::VisitInst(Instruction *Inst, WARDFValType &Param) {

  bool Ret = false;
  // Kill write insts which are written by current inst
  // in(s) - [writes_same_obj, [*, *]]
  ReachDefDFValType ReachDefsPrev = RDInfo->GetInstResult(Inst, true);
  ReachDefDFValType ReachDefsAfter = RDInfo->GetResultAfterInst(Inst, true);
  for (auto it = ReachDefsPrev.ReachDefs.begin(),
            ie = ReachDefsPrev.ReachDefs.end();
       it != ie; ++it) {
    for (auto it1 = it->second.begin(), ie1 = it->second.end(); it1 != ie1;
         ++it1) {
      if (ReachDefsAfter.ReachDefs[it->first].find(*it1) ==
          ReachDefsAfter.ReachDefs[it->first].end()) {
        Ret |= Param.WARDFVal.erase(*it1);
      }
    }
  }
  Ret |= Param.WARDFVal.erase(Inst);

  // (in(s) - [read(s), [pipe(s), *]]) union [read(s), [pipe(s), s]]
  std::set<Value *> Ptrs;
  pipe_t Pipe = GetPipeType(Inst);
  if (LoadInst *LdInst = dyn_cast<LoadInst>(Inst)) {
    Ptrs.insert(LdInst->getPointerOperand());
  } else if (IsHIVMIntrinsic(Inst)) {
    CallInst *Call = dyn_cast<CallInst>(Inst);
    StringRef Callee = Call->getCalledFunction()->getName();
    if (Callee == "llvm.hivm.GET.IMM.16") {
      return false;
    } else if (Callee == "llvm.hivm.MOVEVA") {
      return GetVAStatus(Call, &Param.VA);
    } else if (Callee.startswith("llvm.hivm.S.VNCHWCONV")) {
      // Get src object
      for (Value *Src : Param.VA.Srcs) {
        auto Vals = PTInfo->GetOverlappedPointsToObjsOfVal(Src, Inst);
        Ptrs.insert(Vals.begin(), Vals.end());
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

  for (Value *Ptr : Ptrs) {
    auto AliasObjs = PTInfo->GetOverlappedPointsToObjsOfVal(Ptr, Inst);
    for (Value *Obj : AliasObjs) {
      for (Instruction *Def : ReachDefsPrev.ReachDefs[Obj]) {
        if (Param.WARDFVal.find(Def) != Param.WARDFVal.end()) {
          std::set<std::pair<unsigned, Instruction *>> ToErased;
          for (auto it = Param.WARDFVal[Def].begin(),
                    ie = Param.WARDFVal[Def].end();
               it != ie; ++it) {
            if (it->first == Pipe)
              ToErased.insert(*it);
          }
          for (auto it = ToErased.begin(), ie = ToErased.end(); it != ie;
               ++it) {
            Ret |= Param.WARDFVal[Def].erase(*it);
          }
        }
        Ret |= Param.WARDFVal[Def].insert(std::make_pair(Pipe, Inst)).second;
      }
    }
  }

  return Ret;
}

bool WARDFVisitor::Merge(WARDFValType &Dst, const WARDFValType &Src) {
  bool Ret = false;
  for (auto it = Src.WARDFVal.begin(), ie = Src.WARDFVal.end(); it != ie;
       ++it) {
    for (auto it1 = it->second.begin(), ie1 = it->second.end(); it1 != ie1;
         ++it1) {
      Ret |= Dst.WARDFVal[it->first]
                 .insert(std::make_pair(it1->first, it1->second))
                 .second;
    }
  }
  for (auto it = Src.VA.Srcs.begin(), ie = Src.VA.Srcs.end(); it != ie; ++it) {
    Ret |= Dst.VA.Srcs.insert(*it).second;
  }
  for (auto it = Src.VA.Dsts.begin(), ie = Src.VA.Dsts.end(); it != ie; ++it) {
    Ret |= Dst.VA.Dsts.insert(*it).second;
  }
  return Ret;
}

void WARInfo::Initialize() {
  WARDFValType tmp;
  InitializeExitResult(tmp);
}

void WARInfo::CollectWARPairs() {
  Function *F = GetFunction();
  WARDFValType DFValPrev;
  for (Instruction &Inst : instructions(F)) {
    pipe_t PipeDst = GetPipeType(&Inst);
    if (&Inst == &(Inst.getParent()->front()))
      DFValPrev = GetInstResult(&Inst, true);
    WARDFValType DFValAfter = DFValPrev;
    GetVistor()->VisitInst(&Inst, DFValAfter);
    for (auto it = DFValPrev.WARDFVal.begin(), ie = DFValPrev.WARDFVal.end();
         it != ie; ++it) {
      for (auto it1 = it->second.begin(), ie1 = it->second.end(); it1 != ie1;
           ++it1) {
        bool Found = false;
        pipe_t PipeSrc = GetPipeType(it1->second);
        if (PipeSrc == PIPE_S && PipeDst == PIPE_S)
          continue;
        for (auto it2 = DFValAfter.WARDFVal[it->first].begin(),
                  ie2 = DFValAfter.WARDFVal[it->first].end();
             it2 != ie2; ++it2) {
          if (it2->first == it1->first) {
            Found = true;
            break;
          }
        }
        if (!Found) {
          WARPairs.insert(std::make_pair(it1->second, &Inst));
        }
      }
    }
    DFValPrev = DFValAfter;
  }
}

void WARInfo::print(raw_ostream &Out) {
  Out << "---------Result Of Write-after-read Analysis---------\n";
  for (auto it = WARPairs.begin(), ie = WARPairs.end(); it != ie; ++it) {
    llvm::errs() << "Src: " << *(it->first) << ", Dst: " << *(it->second)
                 << '\n';
  }
}

void HACLWARAnalysis::print(raw_ostream &Out, const Module *Module) const {
  info->print(Out);
}

bool HACLWARAnalysis::runOnFunction(Function &F) {
  auto &PTInfo = getAnalysis<HACLBasicPointsToAnalysis>().getResult();
  auto &RDInfo = getAnalysis<HACLReachDefinitionAnalysis>().getResult();
  WARInfo *Result = new WARInfo(&F, &PTInfo, &RDInfo);
  Result->ComputeForwardDataFlow();
  Result->CollectWARPairs();
  info.reset(Result);
  return false;
}

WARInfo &HACLWARAnalysis::getResult() const { return *info; }

void HACLWARAnalysis::releaseMemory() { info.reset(); }

void HACLWARAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLBasicPointsToAnalysis>();
  AU.addRequiredTransitive<HACLReachDefinitionAnalysis>();
}