#include "llvm/Analysis/HACL/LiveIntervalAnalysis.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLLiveIntervalAnalysis, "hacl-liveinterval",
                      "HACL Live Interval Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLLiveVariableAnalysis)
INITIALIZE_PASS_DEPENDENCY(HACLReachDefinitionAnalysis)
INITIALIZE_PASS_END(HACLLiveIntervalAnalysis, "hacl-liveinterval",
                    "HACL Live Interval Analysis", false, true)

char HACLLiveIntervalAnalysis::ID = 0;

FunctionPass *llvm::createHACLLiveIntervalAnalysisPass() {
  return new HACLLiveIntervalAnalysis();
}

bool HACLLiveIntervalAnalysis::runOnFunction(Function &F) {
  auto &LV = getAnalysis<HACLLiveVariableAnalysis>().getResult();
  auto &RD = getAnalysis<HACLReachDefinitionAnalysis>().getResult();
  info.reset(new IntervalInfo(&F, &LV, &RD));
  return false;
}

IntervalInfo &HACLLiveIntervalAnalysis::getResult() const { return *info; }

void HACLLiveIntervalAnalysis::releaseMemory() { info.reset(); }

void HACLLiveIntervalAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLLiveVariableAnalysis>();
  AU.addRequiredTransitive<HACLReachDefinitionAnalysis>();
}

void HACLLiveIntervalAnalysis::print(raw_ostream &Out,
                                     const Module *Module) const {
  info->print(Out);
}

void IntervalInfo::print(raw_ostream &Out) {
  Out << "---------Result of Live Interval Analysis---------\n";
  for (auto IT = IntervalOfVals.begin(), IE = IntervalOfVals.end(); IT != IE;
       ++IT) {
    Value *Val = IT->first;
    Out << "Value: " << *Val << ",\n";
    Out << "[" << IT->second.first << ", " << IT->second.second << "]\n";
  }
}

void IntervalInfo::ComputeIntervals() {
  unsigned ID = 0;
  ReversePostOrderTraversal<Function *> RPOT(F);
  std::map<Instruction *, unsigned> Objs;
  for (auto RI = RPOT.begin(), RE = RPOT.end(); RI != RE; ++RI) {
    BasicBlock *BB = *RI;
    for (auto BI = BB->begin(), BE = BB->end(); BI != BE; ++BI, ++ID) {
      Instruction *Val = &*BI;
      if (isa<CallInst>(Val) &&
          cast<CallInst>(Val)->getCalledFunction()->getIntrinsicID() ==
              Intrinsic::hivm_GET_ADDR)
        Objs[Val] = ID;
      LiveVarDFValType LVVal = LV->GetInstResult(Val, false);
      ReachDefDFValType RDVal = RD->GetInstResult(Val, true);
      for (auto IT = RDVal.ReachDefs.begin(), IE = RDVal.ReachDefs.end();
           IT != IE; ++IT) {
        Instruction *Val = dyn_cast<Instruction>(IT->first);
        if (!Val)
          continue;
        if (IntervalOfVals.find(Val) == IntervalOfVals.end() &&
            Objs.find(Val) != Objs.end()) {
          if (Objs[Val] == ID)
            IntervalOfVals[Val] = std::make_pair(ID, ID);
          else
            IntervalOfVals[Val] = std::make_pair(ID - 1, ID - 1);
        }
      }
      for (auto IT = LVVal.begin(), IE = LVVal.end(); IT != IE; ++IT) {
        Instruction *Val = *IT;
        if (IntervalOfVals.find(Val) != IntervalOfVals.end())
          IntervalOfVals[Val].second = ID + 1;
      }
    }
  }

  // If we get no live range for one object, set its live range to [0, 0]
  for (auto IT = Objs.begin(), IE = Objs.end(); IT != IE; ++IT) {
    Instruction *Obj = IT->first;
    if (IntervalOfVals.find(Obj) == IntervalOfVals.end())
      IntervalOfVals[Obj] = std::make_pair(0, 0);
  }

  // For cloned buffer, set its live interval as its source buffer
  for (auto IT = Objs.begin(), IE = Objs.end(); IT != IE; ++IT) {
    Instruction *Obj = IT->first;
    CallInst *Call = dyn_cast<CallInst>(Obj);
    if (MDNode *MDNode = Call->getMetadata("cloned_from")) {
      ValueAsMetadata *MD =
          dyn_cast<ValueAsMetadata>(MDNode->getOperand(0).get());
      Instruction *Src = dyn_cast<Instruction>(MD->getValue());
      IntervalOfVals[Obj] = IntervalOfVals[Src];
    }
  }
}