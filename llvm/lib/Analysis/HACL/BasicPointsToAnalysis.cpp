#include "llvm/Analysis/HACL/BasicPointsToAnalysis.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLBasicPointsToAnalysis, "hacl-pta",
                      "HACL Basic Points-to Analysis", false, true)
INITIALIZE_PASS_END(HACLBasicPointsToAnalysis, "hacl-pta",
                    "HACL Basic Points-to Analysis", false, true)

char HACLBasicPointsToAnalysis::ID = 0;

bool PointsToDFVisitor::VisitInst(Instruction *Inst, PointsToDFValType &Param) {
  bool Ret = false;
  if (!Inst->getType()->isPointerTy() && !isa<StoreInst>(Inst) &&
      !isa<LoadInst>(Inst))
    return false;
  if (CallInst *Call = dyn_cast<CallInst>(Inst)) {
    Function *Callee = Call->getCalledFunction();
    if (Callee && Callee->getIntrinsicID() == Intrinsic::hivm_GET_ADDR) {
      Param.erase(Inst);
      Param[Inst].insert(Inst);
      Ret = true;
    }
  } else if (IntToPtrInst *IntToPtr = dyn_cast<IntToPtrInst>(Inst)) {
    if (CallInst *Call = dyn_cast<CallInst>(IntToPtr->getOperand(0))) {
      Function *Callee = Call->getCalledFunction();
      if (Callee && Callee->getIntrinsicID() == Intrinsic::hivm_GET_IMM_16) {
        Param.erase(Inst);
        Param[Inst].insert(Inst);
        Ret = true;
      }
    }
  } else if (isa<AllocaInst>(Inst)) {
    Param.erase(Inst);
    Param[Inst].insert(Inst);
    Ret = true;
  } else if (BitCastInst *Cast = dyn_cast<BitCastInst>(Inst)) {
    Param[Inst] = Param[Cast->getOperand(0)];
    Ret = true;
  } else if (PHINode *Phi = dyn_cast<PHINode>(Inst)) {
    Param.erase(Inst);
    for (Value *Val : Phi->operands()) {
      Param[Inst].insert(Param[Val].begin(), Param[Val].end());
    }
    Ret = true;
  } else if (GetElementPtrInst *Gep = dyn_cast<GetElementPtrInst>(Inst)) {
    Param[Inst] = Param[Gep->getPointerOperand()];
    Ret = true;
  } else if (LoadInst *Ld = dyn_cast<LoadInst>(Inst)) {
    Param.erase(Inst);
    auto &PointsTo = Param[Ld->getPointerOperand()];
    for (auto IT = PointsTo.begin(), IE = PointsTo.end(); IT != IE; ++IT) {
      Param[Inst].insert(Param[*IT].begin(), Param[*IT].end());
    }
  } else if (StoreInst *St = dyn_cast<StoreInst>(Inst)) {
    if (!St->getValueOperand()->getType()->isPointerTy())
      return false;
    auto &PtrPointsTo = Param[St->getPointerOperand()];
    auto &ValPointsTo = Param[St->getValueOperand()];
    if (PtrPointsTo.size() == 1) {
      Value *Ptr = *PtrPointsTo.begin();
      Param[Ptr] = ValPointsTo;
    } else {
      for (Value *Ptr : PtrPointsTo) {
        Param[Ptr].insert(ValPointsTo.begin(), ValPointsTo.end());
      }
    }
  }
  return Ret;
}

bool PointsToDFVisitor::Merge(PointsToDFValType &Dst,
                              const PointsToDFValType &Src) {
  bool Ret = false;
  for (auto IT = Src.begin(), IE = Src.end(); IT != IE; ++IT) {
    for (auto IT1 = IT->second.begin(), IE1 = IT->second.end(); IT1 != IE1;
         ++IT1) {
      Ret |= Dst[IT->first].insert(*IT1).second;
    }
  }
  return Ret;
}

void PointsToInfo::CollectBaseObjAliasInfo() {
  std::set<Instruction *> Objs = CollectObjects(GetFunction());
  for (Instruction *Obj0 : Objs) {
    if (!isa<IntToPtrInst>(Obj0))
      continue;
    unsigned AddrSpace0 = Obj0->getType()->getPointerAddressSpace();
    if (AddrSpace0 != 2 && AddrSpace0 != 6)
      continue;
    CallInst *GetIMM0 = cast<CallInst>(Obj0->getOperand(0));
    ConstantInt *MD0 =
        mdconst::extract<ConstantInt>(Obj0->getMetadata("size")->getOperand(0));
    uint64_t Size0 = MD0->getValue().getZExtValue();
    uint64_t Addr0 = cast<ConstantInt>(GetIMM0->getOperand(0))->getZExtValue();
    for (Instruction *Obj1 : Objs) {
      if (OverlappedObjs[Obj0].find(Obj1) != OverlappedObjs[Obj0].end())
        continue;
      if (!isa<IntToPtrInst>(Obj1))
        continue;
      unsigned AddrSpace1 = Obj1->getType()->getPointerAddressSpace();
      if (AddrSpace0 != AddrSpace1)
        continue;
      CallInst *GetIMM1 = cast<CallInst>(Obj1->getOperand(0));
      ConstantInt *MD1 = mdconst::extract<ConstantInt>(
          Obj1->getMetadata("size")->getOperand(0));
      uint64_t Size1 = MD1->getValue().getZExtValue();
      uint64_t Addr1 =
          cast<ConstantInt>(GetIMM1->getOperand(0))->getZExtValue();
      if ((Addr0 < Addr1 + Size1 && Addr0 >= Addr1) ||
          (Addr1 < Addr0 + Size0 && Addr1 >= Addr0)) {
        OverlappedObjs[Obj1].insert(Obj0);
        OverlappedObjs[Obj0].insert(Obj1);
      }
    }
  }
}

void PointsToInfo::Initialize() {
  PointsToDFValType tmp;
  for (Argument &Arg : GetFunction()->args()) {
    if (Arg.getType()->isPointerTy())
      tmp[&Arg].insert(&Arg);
  }
  InitializeEntryResult(tmp);
  CollectBaseObjAliasInfo();
}

std::set<Value *> PointsToInfo::GetPointsToObjsOfVal(Value *Val,
                                                     Instruction *Pos) {
  PointsToDFValType DFVal = GetInstResult(Pos, true);
  return DFVal[Val];
}

std::set<Value *>
PointsToInfo::GetOverlappedPointsToObjsOfVal(Value *Val, Instruction *Pos) {
  PointsToDFValType DFVal = GetInstResult(Pos, true);
  std::set<Value *> Res;
  for (auto &Obj : DFVal[Val]) {
    if (OverlappedObjs[Obj].size() == 0)
      Res.insert(Obj);
    else
      Res.insert(OverlappedObjs[Obj].begin(), OverlappedObjs[Obj].end());
  }
  return Res;
}

void PointsToInfo::print(raw_ostream &Out) {
  Function *F = GetFunction();
  Out << "---------Result Of Points-to Analysis---------\n";
  for (BasicBlock &BB : *F) {
    PointsToDFValType DFVal = GetBBEntryResult(&BB);
    Out << "BB: " << BB.front() << '\n';
    for (auto IT = DFVal.begin(), IE = DFVal.end(); IT != IE; ++IT) {
      Out << "Pointer: " << *IT->first << ", Points to:\n";
      for (auto IT1 = IT->second.begin(), IE1 = IT->second.end(); IT1 != IE1;
           ++IT1) {
        Out << **IT1 << '\n';
      }
    }
  }
}

void HACLBasicPointsToAnalysis::print(raw_ostream &Out,
                                      const Module *Module) const {
  info->print(Out);
}

bool HACLBasicPointsToAnalysis::runOnFunction(Function &F) {
  PointsToInfo *Result = new PointsToInfo(&F);
  Result->ComputeForwardDataFlow();
  info.reset(Result);
  return false;
}

PointsToInfo &HACLBasicPointsToAnalysis::getResult() const { return *info; }

void HACLBasicPointsToAnalysis::releaseMemory() { info.reset(); }

void HACLBasicPointsToAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
}

FunctionPass *llvm::createHACLBasicPointsToAnalysisPass() {
  return new HACLBasicPointsToAnalysis();
}