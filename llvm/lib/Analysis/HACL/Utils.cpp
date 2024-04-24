#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicsHivm.h"
#include <map>

bool IsHIVMIntrinsic(const Instruction *Inst) {
  const CallInst *Call = dyn_cast<CallInst>(Inst);
  if (!Call)
    return false;
  Function *Func = Call->getCalledFunction();
  if (!Func || !Func->hasName())
    return false;
  if (Func->getName().startswith("llvm.hivm"))
    return true;
  return false;
}

bool IsGemmIntrinsic(const Instruction *Inst) {
  const CallInst *Call = dyn_cast<CallInst>(Inst);
  if (!Call)
    return false;
  Function *Func = Call->getCalledFunction();
  if (!Func || !Func->hasName())
    return false;
  if (Func->getName().startswith("llvm.hivm.MAD"))
    return true;
  return false;
}

std::set<Instruction *> CollectObjects(Function *Func) {
  std::set<Instruction *> Objs;
  for (Instruction &Inst : instructions(Func)) {
    if (CallInst *Call = dyn_cast<CallInst>(&Inst)) {
      if (Call->getCalledFunction()->getIntrinsicID() ==
          llvm::Intrinsic::hivm_GET_ADDR)
        Objs.insert(&Inst);
    } else if (IntToPtrInst *Cast = dyn_cast<IntToPtrInst>(&Inst)) {
      if (CallInst *Call = dyn_cast<CallInst>(Cast->getOperand(0))) {
        if (Call->getCalledFunction()->getIntrinsicID() ==
            llvm::Intrinsic::hivm_GET_IMM_16)
          Objs.insert(&Inst);
      }
    }
  }
  return Objs;
}

pipe_t GetPipeType(const Instruction *Inst) {
  if (!IsHIVMIntrinsic(Inst))
    return PIPE_S;
  const CallInst *Call = dyn_cast<CallInst>(Inst);
  StringRef FuncName = Call->getCalledFunction()->getName();
  if (FuncName.startswith("llvm.hivm.V") ||
      FuncName.startswith("llvm.hivm.MOVEV") ||
      FuncName.startswith("llvm.hivm.S.VNCHWCONV") ||
      FuncName == "llvm.hivm.MOV.UB.TO.UB" ||
      FuncName.startswith("llvm.hivm.MOV.L0C") ||
      FuncName.startswith("llvm.hivm.MOV.UB.TO.L0C"))
    return PIPE_V;
  if (FuncName.startswith("llvm.hivm.MAD"))
    return PIPE_M;
  if (FuncName.startswith("llvm.hivm.LOAD.L1"))
    return PIPE_LSU1;
  if (FuncName.startswith("llvm.hivm.MOV.OUT"))
    return PIPE_LSU2;
  if (FuncName.startswith("llvm.hivm.MOV.UB"))
    return PIPE_LSU3;
  return PIPE_S;
}

bool GetVAStatus(CallInst *Call, VAStatus *Status) {
  if (!Call->getCalledFunction())
    return false;
  if (Call->getCalledFunction()->getIntrinsicID() != Intrinsic::hivm_MOVEVA)
    return false;
  bool Ret = false;
  ConstantInt *Const0 = dyn_cast<ConstantInt>(Call->getArgOperand(0));
  ConstantInt *Const1 = dyn_cast<ConstantInt>(Call->getArgOperand(1));
  if (!Const0 || !Const1)
    return false;
  uint64_t VAID0 = Const0->getZExtValue();
  uint64_t VAID1 = Const1->getZExtValue();
  if (VAID1 != 0)
    return false;
  if (VAID0 == 0) {
    Status->Dsts.clear();
    Status->Dsts.insert(Call->getArgOperand(2));
    Ret = true;
  } else if (VAID0 == 2) {
    Status->Srcs.clear();
    Status->Srcs.insert(Call->getArgOperand(2));
    Ret = true;
  }
  return Ret;
}

static void GetBasePointer(Value *Ptr, std::set<Value *> &Visited,
                           std::set<Value *> &Res) {
  if (Visited.find(Ptr) != Visited.end())
    return;
  Visited.insert(Ptr);
  if (PHINode *PHI = dyn_cast<PHINode>(Ptr)) {
    for (Value *Op : PHI->operands()) {
      GetBasePointer(Op, Visited, Res);
    }
  } else if (CastInst *Cast = dyn_cast<CastInst>(Ptr)) {
    GetBasePointer(Cast->getOperand(0), Visited, Res);
  } else if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Ptr)) {
    GetBasePointer(GEP->getOperand(0), Visited, Res);
  } else {
    Res.insert(Ptr);
  }
}

static void GetAliasPointers(Instruction *Ptr, std::set<Instruction *> &Visited,
                             std::set<Instruction *> &Res) {
  if (Visited.find(Ptr) != Visited.end())
    return;
  Visited.insert(Ptr);
  Res.insert(Ptr);
  for (auto IT = Ptr->use_begin(), IE = Ptr->use_end(); IT != IE; ++IT) {
    Use *U = &*IT;
    Instruction *Inst = dyn_cast<Instruction>(U->getUser());
    if (isa<CastInst>(Inst) || isa<GetElementPtrInst>(Inst) ||
        isa<PHINode>(Inst)) {
      GetAliasPointers(Inst, Visited, Res);
    }
  }
}

// Check whether BB2 is reachable from BB1
static bool IsReachable(BasicBlock *BB1, BasicBlock *BB2) {
  static std::map<std::pair<BasicBlock *, BasicBlock *>, bool> CacheResult;
  std::pair<BasicBlock *, BasicBlock *> Pair(BB1, BB2);
  if (CacheResult.find(Pair) != CacheResult.end())
    return CacheResult[Pair];
  if (BB1 == BB2) {
    CacheResult[Pair] = true;
    return true;
  }
  std::vector<BasicBlock *> Succs;
  std::set<BasicBlock *> Visited;
  Succs.push_back(BB1);
  Visited.insert(BB1);
  while (!Succs.empty()) {
    BasicBlock *bb = Succs.back();
    Succs.pop_back();
    for (llvm::succ_iterator SI = succ_begin(bb), SE = succ_end(bb); SI != SE;
         ++SI) {
      if (*SI == BB2) {
        CacheResult[Pair] = true;
        return true;
      }
      if (Visited.find(*SI) == Visited.end()) {
        Visited.insert(*SI);
        Succs.push_back(*SI);
      }
    }
  }
  CacheResult[Pair] = false;
  return false;
}

// Check whether Inst2 is reachable from Inst1
static bool IsReachable(Instruction *Inst1, Instruction *Inst2) {
  if (Inst1 == Inst2)
    return false;
  BasicBlock *BB1 = Inst1->getParent(), *BB2 = Inst2->getParent();
  // Two instructions are at different basicblock
  if (BB1 != BB2)
    return IsReachable(BB1, BB2);
  // Two instructions are at one basicblock
  for (auto IT = BB1->begin(), IE = BB1->end(); IT != IE; ++IT) {
    if (&*IT == Inst1)
      return true;
    if (&*IT == Inst2)
      return false;
  }
  return false;
}

std::set<Value *> GetAliasPointersForVA(Value *Val, Instruction *Pos) {
  std::set<Value *> Res;
  Val = Val->stripPointerCasts();
  std::vector<Value *> work_list;
  work_list.push_back(Val);
  while (!work_list.empty()) {
    Value *Cur = work_list.back();
    work_list.pop_back();
    if (PHINode *PHI = dyn_cast<PHINode>(Cur)) {
      for (unsigned i = 0, n = PHI->getNumIncomingValues(); i < n; ++i) {
        work_list.push_back(PHI->getIncomingValue(i));
      }
    } else {
      if (LoadInst *LD = dyn_cast<LoadInst>(Cur)) {
        std::set<Value *> Visited, Objs;
        GetBasePointer(LD->getPointerOperand(), Visited, Objs);

        std::set<Instruction *> VisitedPtrs, Ptrs;
        for (auto IT = Objs.begin(), IE = Objs.end(); IT != IE; ++IT) {
          Instruction *Inst = dyn_cast<Instruction>(*IT);
          if (!Inst)
            continue;
          GetAliasPointers(Inst, VisitedPtrs, Ptrs);
        }
        for (auto IT = Ptrs.begin(), IE = Ptrs.end(); IT != IE; ++IT) {
          Instruction *Inst = dyn_cast<Instruction>(*IT);
          for (auto IT1 = Inst->use_begin(), IE1 = Inst->use_end(); IT1 != IE1;
               ++IT1) {
            Use *U = &*IT1;
            StoreInst *St = dyn_cast<StoreInst>(U->getUser());
            if (!St || St->getPointerOperand() != Inst || !IsReachable(St, Pos))
              continue;
            Res.insert(St->getValueOperand());
          }
        }
      }
    }
  }
  return Res;
}
