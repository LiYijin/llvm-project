#include "llvm/Transforms/Scalar/HACL/MemAllocaTransform.h"
#include "llvm/Analysis/HACL/MemoryAllocation.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLMemAllocaTransform, "hacl-memalloctransform",
                      "HACL Memory Allocation Transform", false, false)
INITIALIZE_PASS_DEPENDENCY(HACLMemoryAllocation)
INITIALIZE_PASS_END(HACLMemAllocaTransform, "hacl-memalloctransform",
                    "HACL Memory Allocation Transform", false, false)

char HACLMemAllocaTransform::ID = 0;

FunctionPass *llvm::createHACLMemAllocaTransformPass() {
  return new HACLMemAllocaTransform();
}

static Function *getIntrinsic(Function &F, Intrinsic::ID IID,
                              ArrayRef<Type *> Tys = std::nullopt) {
  return Intrinsic::getDeclaration(F.getParent(), (Intrinsic::ID)IID, Tys);
}

static bool isMismatchCall(CallInst *Call) {
  Function *Func = Call->getCalledFunction();
  FunctionType *FTy = Func->getFunctionType();
  for (unsigned I = 0; I < Call->arg_size(); ++I) {
    Type *ArgTy = Call->getArgOperand(I)->getType();
    Type *ParamTy = FTy->getFunctionParamType(I);
    if (!ArgTy->isPointerTy())
      continue;
    if (ArgTy->getPointerAddressSpace() != ParamTy->getPointerAddressSpace())
      return true;
  }
  return false;
}

Instruction *HACLMemAllocaTransform::transformInst(Instruction *Inst) {
  IRBuilder<> Builder(Inst->getContext());
  Instruction *NewInst = nullptr;
  if (CastInst *CI = dyn_cast<CastInst>(Inst)) {
    // Skip AddrSpaceCastInst
    if (isa<AddrSpaceCastInst>(Inst))
      return nullptr;
    // For other cases, addrspace of dst should be the same as src's
    Type *SrcTy = CI->getOperand(0)->getType(), *DstTy = CI->getType();
    if (!SrcTy->isPointerTy() || !DstTy->isPointerTy())
      return nullptr;
    if (isa<BitCastInst>(CI)) {
      if (SrcTy->getPointerAddressSpace() != DstTy->getPointerAddressSpace())
        NewInst = cast<Instruction>(Builder.CreateBitCast(
            CI->getOperand(0),
            PointerType::get(DstTy->getContext(),
                             SrcTy->getPointerAddressSpace())));
    }
  } else if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Inst)) {
    // For GEP, type of inst should be updated
    SmallVector<Value *, 3> Idxs;
    for (unsigned i = 0, n = GEP->getNumIndices(); i < n; ++i) {
      Idxs.push_back(GEP->getOperand(i + 1));
    }
    NewInst = cast<Instruction>(Builder.CreateGEP(GEP->getSourceElementType(),
                                                  GEP->getOperand(0), Idxs));
  } else if (CallInst *Call = dyn_cast<CallInst>(Inst)) {
    Function *Func = Call->getCalledFunction();
    if (!Func || !Func->hasName())
      return nullptr;
    if (!Func->getName().startswith("llvm.hivm.MOV"))
      return nullptr;
    if (!isMismatchCall(Call))
      return nullptr;
    bool IsGM2L1 = false;
    Function *NewFunc = nullptr;
    Function &ParentFunction = *(Inst->getFunction());
    Intrinsic::ID IID = Func->getIntrinsicID();
    switch (IID) {
    default:
      break;
    case Intrinsic::hivm_MOV_OUT_TO_UB: {
      if (Call->getArgOperand(0)->getType()->getPointerAddressSpace() == 2) {
        NewFunc = getIntrinsic(ParentFunction, Intrinsic::hivm_MOV_OUT_TO_L1);
        IsGM2L1 = true;
      }
      break;
    }
    case Intrinsic::hivm_MOV_UB_TO_OUT: {
      if (Call->getArgOperand(1)->getType()->getPointerAddressSpace() == 2) {
        // No real data move path, this case should be handled in tiling step
        NewFunc = getIntrinsic(ParentFunction, Intrinsic::hivm_MOV_L1_TO_OUT);
      }
      break;
    }
    case Intrinsic::hivm_MOV_UB_TO_UB: {
      unsigned DstAddrSpace =
          Call->getArgOperand(0)->getType()->getPointerAddressSpace();
      unsigned SrcAddrSpace =
          Call->getArgOperand(1)->getType()->getPointerAddressSpace();
      if (DstAddrSpace == 2 && SrcAddrSpace == 2) {
        // No real data move path, this case should be handled in tiling step
        NewFunc = getIntrinsic(ParentFunction, Intrinsic::hivm_MOV_L1_TO_L1);
      } else if (DstAddrSpace == 2) {
        NewFunc = getIntrinsic(ParentFunction, Intrinsic::hivm_MOV_UB_TO_L1);
      } else {
        NewFunc = getIntrinsic(ParentFunction, Intrinsic::hivm_MOV_L1_TO_UB);
      }
      break;
    }
    }
    if (NewFunc) {
      if (IsGM2L1 && Call->arg_size() != NewFunc->getNumOperands()) {
        NewInst = Builder.CreateCall(
            NewFunc,
            {Call->getArgOperand(0), Call->getArgOperand(1),
             Call->getArgOperand(2),
             ConstantInt::get(IntegerType::getInt64Ty(Inst->getContext()), 0)});
      } else {
        Call->setCalledFunction(NewFunc);
      }
    }
  }

  if (NewInst) {
    NewInst->insertBefore(Inst);
    Inst->replaceAllUsesWith(NewInst);
    Inst->eraseFromParent();
  }
  return NewInst;
}

static void updateWorkList(Instruction *Inst,
                           std::vector<Instruction *> &WorkList) {
  for (Use &U : Inst->uses()) {
    Instruction *UseInst = dyn_cast<Instruction>(U.getUser());
    if (!UseInst)
      continue;
    WorkList.push_back(UseInst);
  }
}

void HACLMemAllocaTransform::RemoveUnusedObject(Instruction *Inst) {
  std::set<Instruction *> Visited, Removed;
  std::vector<Instruction *> WorkList;
  WorkList.push_back(Inst);
  while (!WorkList.empty()) {
    Instruction *Val = WorkList.back();
    WorkList.pop_back();
    if (Visited.find(Val) != Visited.end())
      continue;
    Visited.insert(Val);
    Removed.insert(Val);
    for (User *U : Val->users()) {
      Instruction *Inst = dyn_cast<Instruction>(U);
      if (!Inst)
        continue;
      Removed.insert(Inst);
      WorkList.push_back(Inst);
    }
  }
  for (Instruction *Inst : Removed) {
    Inst->eraseFromParent();
  }
}

bool HACLMemAllocaTransform::runOnFunction(Function &F) {

  errs() << "Before HACL Memory Allocation Transform Pass:\n";
  errs() << F << "\n";

  auto &MAI = getAnalysis<HACLMemoryAllocation>().getResult();
  auto &AddrMap = MAI.getAllAddressInfo();
  IRBuilder<> Builder(F.getContext());
  std::vector<Instruction *> WorkList;
  LLVMContext &Context = F.getContext();
  Function *GetIMM = getIntrinsic(F, Intrinsic::hivm_GET_IMM_16);
  for (auto IT = AddrMap.begin(), IE = AddrMap.end(); IT != IE; ++IT) {
    Instruction *Val = IT->first;
    AddressInfo Addr = IT->second;
    // Remove instructions for unused object.
    if (Addr.second.second == 0) {
      RemoveUnusedObject(Val);
      continue;
    }
    llvm::SmallVector<Value *, 1> Ops;
    Ops.push_back(
        llvm::ConstantInt::get(Type::getInt64Ty(Context), Addr.second.first));
    Builder.SetInsertPoint(&F.getEntryBlock(),
                           F.getEntryBlock().getFirstInsertionPt());
    Value *IMM = Builder.CreateCall(GetIMM, Ops, "");
    Type *PtType = Val->getType();
    Instruction *Ptr = cast<Instruction>(
        Builder.CreateIntToPtr(IMM, PointerType::get(PtType->getContext(), Addr.first)));
    Metadata *MD = ValueAsMetadata::get(
        ConstantInt::get(Type::getInt64Ty(Context), Addr.second.second));
    Ptr->setMetadata("size", MDNode::get(Context, MD));
    updateWorkList(Val, WorkList);
    Val->replaceAllUsesWith(Ptr);
    Val->eraseFromParent();
  }

  while (!WorkList.empty()) {
    Instruction *Inst = WorkList.back();
    WorkList.pop_back();
    Instruction *NewInst = transformInst(Inst);
    if (NewInst)
      updateWorkList(NewInst, WorkList);
  }

  errs() << "After HACL Memory Allocation Transform Pass:\n";
  errs() << F << "\n";
  return !AddrMap.empty();
}

void HACLMemAllocaTransform::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesCFG();
  AU.addRequiredTransitive<HACLMemoryAllocation>();
}