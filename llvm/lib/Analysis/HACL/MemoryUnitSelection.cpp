#include "llvm/Analysis/HACL/MemoryUnitSelection.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLMemoryUnitSelection, "hacl-memunitselect",
                      "HACL Memory Unit Selection", false, true)
INITIALIZE_PASS_END(HACLMemoryUnitSelection, "hacl-memunitselect",
                    "HACL Memory Unit Selection", false, true)

char HACLMemoryUnitSelection::ID = 0;

FunctionPass *llvm::createHACLMemoryUnitSelectionPass() {
  return new HACLMemoryUnitSelection();
}

static bool IsHIVMVectorIntrinsic(Instruction *Inst) {
  CallInst *Call = dyn_cast<CallInst>(Inst);
  if (!Call)
    return false;
  Function *Func = Call->getCalledFunction();
  if (!Func || !Func->hasName())
    return false;
  if (Func->getName().startswith("llvm.hivm.V") ||
      Func->getName().startswith("llvm.hivm.MOVEV"))
    return true;
  return false;
}

static bool IsHIVMMatrixIntrinsic(Instruction *Inst) {
  CallInst *Call = dyn_cast<CallInst>(Inst);
  if (!Call)
    return false;
  Function *Func = Call->getCalledFunction();
  if (!Func || !Func->hasName())
    return false;
  if (Func->getName().startswith("llvm.hivm.MAD"))
    return true;
  return false;
}

static void SelectMemoryUnit(Value *Val, MemoryUnit *MU) {
  for (auto IT = Val->use_begin(), IE = Val->use_end(); IT != IE; ++IT) {
    Use *U = &*IT;
    Instruction *Inst = dyn_cast<Instruction>(U->getUser());
    if (!Inst)
      continue;
    if (isa<GetElementPtrInst>(Inst) || isa<CastInst>(Inst)) {
      SelectMemoryUnit(Inst, MU);
    } else if (IsHIVMVectorIntrinsic(Inst)) {
      if (*MU == Undefined)
        *MU = UB;
    } else if (IsHIVMMatrixIntrinsic(Inst)) {
      if (Inst->getOperand(0) == Val) { // dst
        *MU = UB;
      } else if (*MU == Undefined) {
        *MU = L1;
      }
    }
  }
}

void MemoryUnitInfo::doAnalysis() {
  for (Instruction &Inst : instructions(F)) {
    CallInst *Call = dyn_cast<CallInst>(&Inst);
    if (!Call || !Call->getCalledFunction())
      continue;
    if (Call->getCalledFunction()->getIntrinsicID() ==
        Intrinsic::hivm_GET_ADDR) {
      MemoryUnit MU = Undefined;
      SelectMemoryUnit(Call, &MU);
      // Current object is never used by hivm compute intrinsic.
      // 1. If it's used by data move from UB to OUT, allocate it to UB for the
      // reason of data path.
      // 2. If it's used by data move from UB to UB,
      //  (1) If the other operand is allocated to L1, then current object
      //  should be allocated to UB for the reason of data path. (2) If the
      //  other operand is allocated to UB, then allocate current object to UB
      //  may omit actual data move.
      if (MU == Undefined)
        MU = UB;
      Objects.insert(Call);
      ObjMemUnitMap[Call] = MU;
    }
  }
}

void MemoryUnitInfo::print(raw_ostream &Out) {
  Out << "---------Result Of Memory Unit Selection Analysis---------\n";
  for (auto IT = ObjMemUnitMap.begin(), IE = ObjMemUnitMap.end(); IT != IE;
       ++IT) {
    Out << "Object: " << *(IT->first) << ", Memory Unit: " << IT->second
        << '\n';
  }
}

bool HACLMemoryUnitSelection::runOnFunction(Function &F) {
  info.reset(new MemoryUnitInfo(&F));
  return false;
}

MemoryUnitInfo &HACLMemoryUnitSelection::getResult() const { return *info; }

void HACLMemoryUnitSelection::releaseMemory() { info.reset(); }

void HACLMemoryUnitSelection::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
}