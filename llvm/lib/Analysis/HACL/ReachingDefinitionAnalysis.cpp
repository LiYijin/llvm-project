#include "llvm/Analysis/HACL/ReachingDefinitionAnalysis.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLReachDefinitionAnalysis, "hacl-reachdef",
                      "HACL Reaching Definition Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLBasicPointsToAnalysis)
INITIALIZE_PASS_END(HACLReachDefinitionAnalysis, "hacl-reachdef",
                    "HACL Reaching Definition Analysis", false, true)

char HACLReachDefinitionAnalysis::ID = 0;

FunctionPass *llvm::createHACLReachDefinitionAnalysisPass() {
  return new HACLReachDefinitionAnalysis();
}

bool ReachingDefDFVisitor::VisitInst(Instruction *Inst,
                                     ReachDefDFValType &Param) {
  bool Ret = false;
  std::set<Value *> Ptrs;
  if (IsHIVMIntrinsic(Inst)) {
    CallInst *Call = dyn_cast<CallInst>(Inst);
    Function *Callee = Call->getCalledFunction();
    llvm::Intrinsic::ID IID = Callee->getIntrinsicID();

    if (IID == Intrinsic::hivm_SET_CMPMASK)
      return false;
    if (IID == Intrinsic::hivm_MOVEVA) {
      return GetVAStatus(Call, &Param.VA);
    } else if (Callee->getName().startswith("llvm.hivm.S.VNCHWCONV")) {
      // Get dst object
      for (Value *Dst : Param.VA.Dsts) {
        auto Pointers = PTInfo->GetOverlappedPointsToObjsOfVal(Dst, Inst);
        Ptrs.insert(Pointers.begin(), Pointers.end());
      }
    } else {
      Ptrs.insert(Call->getArgOperand(0));
    }
  } else if (StoreInst *StInst = dyn_cast<StoreInst>(Inst)) {
    Ptrs.insert(StInst->getPointerOperand());
  }

  for (Value *Ptr : Ptrs) {
    auto AliasObjs = PTInfo->GetOverlappedPointsToObjsOfVal(Ptr, Inst);
    for (Value *Obj : AliasObjs) {
      Ret |= Param.ReachDefs.erase(Obj);
      Ret |= Param.ReachDefs[Obj].insert(Inst).second;
    }
  }
  return Ret;
}

bool ReachingDefDFVisitor::Merge(ReachDefDFValType &Dst,
                                 const ReachDefDFValType &Src) {
  bool Ret = false;
  for (auto it = Src.ReachDefs.begin(), ie = Src.ReachDefs.end(); it != ie;
       ++it) {
    for (auto it1 = it->second.begin(), ie1 = it->second.end(); it1 != ie1;
         ++it1) {
      Ret |= Dst.ReachDefs[it->first].insert(*it1).second;
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

void ReachDefinitionInfo::Initialize() {
  ReachDefDFValType tmp;
  InitializeExitResult(tmp);
}

void ReachDefinitionInfo::print(raw_ostream &Out) {
  Function *F = GetFunction();
  Out << "---------Result Of Reaching Definition Analysis---------\n";
  for (Instruction &Inst : instructions(F)) {
    ReachDefDFValType DFVal = GetInstResult(&Inst, true);
    if (!DFVal.ReachDefs.empty())
      Out << "Inst: " << Inst << '\n';
    for (auto it = DFVal.ReachDefs.begin(), ie = DFVal.ReachDefs.end();
         it != ie; ++it) {
      Out << "Obj: " << *(it->first) << "\n";
      Out << "Defs: \n";
      for (auto it1 = it->second.begin(), ie1 = it->second.end(); it1 != ie1;
           ++it1) {
        Out << **it1 << '\n';
      }
      Out << '\n';
    }
  }
}

void HACLReachDefinitionAnalysis::print(raw_ostream &Out,
                                        const Module *Module) const {
  info->print(Out);
}

bool HACLReachDefinitionAnalysis::runOnFunction(Function &F) {
  auto &PTInfo = getAnalysis<HACLBasicPointsToAnalysis>().getResult();
  ReachDefinitionInfo *Result = new ReachDefinitionInfo(&F, &PTInfo);
  Result->ComputeForwardDataFlow();
  info.reset(Result);
  return false;
}

ReachDefinitionInfo &HACLReachDefinitionAnalysis::getResult() const {
  return *info;
}

void HACLReachDefinitionAnalysis::releaseMemory() { info.reset(); }

void HACLReachDefinitionAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLBasicPointsToAnalysis>();
}