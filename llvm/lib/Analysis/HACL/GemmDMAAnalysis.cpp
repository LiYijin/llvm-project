#include "llvm/Analysis/HACL/GemmDMAAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLGemmDMAAnalysis, "hacl-gemmdma",
                      "HACL Gemm DMA Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLGemmStateAnalysis)
INITIALIZE_PASS_DEPENDENCY(HACLGemmLiveVariableAnalysis)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_END(HACLGemmDMAAnalysis, "hacl-gemmdma",
                    "HACL Gemm DMA Analysis", false, true)

char HACLGemmDMAAnalysis::ID = 0;

FunctionPass *llvm::createHACLGemmDMAAnalysisPass() {
  return new HACLGemmDMAAnalysis();
}

bool HACLGemmDMAAnalysis::runOnFunction(Function &F) {
  auto &State = getAnalysis<HACLGemmStateAnalysis>().getResult();
  auto &LV = getAnalysis<HACLGemmLiveVariableAnalysis>().getResult();
  auto &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
  auto &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  info.reset(new GemmDMAInfo(&F, &State, &LV, &LI, &DT));
  return false;
}

GemmDMAInfo &HACLGemmDMAAnalysis::getResult() const { return *info; }

void HACLGemmDMAAnalysis::releaseMemory() { info.reset(); }

void HACLGemmDMAAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLGemmStateAnalysis>();
  AU.addRequiredTransitive<HACLGemmLiveVariableAnalysis>();
  AU.addRequiredTransitive<LoopInfoWrapperPass>();
  AU.addRequiredTransitive<DominatorTreeWrapperPass>();
}

void HACLGemmDMAAnalysis::print(raw_ostream &Out, const Module *Module) const {
  info->print(Out);
}

void GemmDMAInfo::print(raw_ostream &Out) {
  Out << "---------Result of Gemm DMA Analysis---------\n";
  Out << "------Loads------:\n";
  for (auto IT = Res.Loads.begin(), IE = Res.Loads.end(); IT != IE; ++IT) {
    Instruction *Inst = IT->first;
    GemmConfig Config = IT->second;
    Out << "Before " << *Inst << ": \n";
    if (Config.Valid) {
      Out << "Gemm Config: \n";
      Out << "Output matrix: " << *Config.GemmOutput << ", M: " << Config.M
          << ", K: " << Config.K << ", N: " << Config.N << '\n';
    } else {
      Out << "Gemm Config is invalid\n";
    }
  }
  Out << "------Stores------:\n";
  for (auto IT = Res.Stores.begin(), IE = Res.Stores.end(); IT != IE; ++IT) {
    Instruction *Inst = IT->first;
    GemmConfig Config = IT->second;
    Out << "Before " << *Inst << ": \n";
    if (Config.Valid) {
      Out << "Gemm Config: \n";
      Out << "Output matrix: " << *Config.GemmOutput << ", M: " << Config.M
          << ", K: " << Config.K << ", N: " << Config.N << '\n';
    } else {
      Out << "Gemm Config is invalid\n";
    }
  }
}

/// Get config of HACL gemm intrinsics.
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
  IntrinsicInst *GemmIntrinsicInst = dyn_cast<IntrinsicInst>(Gemm);
  if(!GemmIntrinsicInst) {
    llvm::errs() << "Error! GemmDMAAnalysis.cpp: Gemm is not an intrinsic instruction\n";
    exit(-1);
  }
  llvm::Intrinsic::ID gemmIntrinsicInstID = GemmIntrinsicInst->getIntrinsicID();
  if(gemmIntrinsicInstID == llvm::Intrinsic::hivm_MAD_f162f16) {
    Config->OutputTy = Type::getHalfTy(Gemm->getContext());
  } else if(gemmIntrinsicInstID == llvm::Intrinsic::hivm_MAD_f162f32) {
    Config->OutputTy = Type::getFloatTy(Gemm->getContext());
  } else {
    Config->OutputTy = Type::getInt32Ty(Gemm->getContext());
  }
  // The following code is deprecated.
  // Config->OutputTy = Gemm->getOperand(0)->getType();

  Config->Valid = true;
}

static bool NoGemmInLoop(Loop *L) {
  static std::map<Loop *, bool> CachedResult;
  if (CachedResult.find(L) != CachedResult.end())
    return CachedResult[L];
  bool Res = true;
  for (BasicBlock *BB : L->blocks()) {
    for (Instruction &Inst : *BB) {
      if (IsGemmIntrinsic(&Inst)) {
        Res = false;
        break;
      }
    }
  }
  CachedResult[L] = Res;
  return Res;
}

void GemmDMAInfo::CheckReadOrWriteUBObject(Instruction *Inst, Value *UBObj,
                                           bool *Read, bool *Write) {
  PointsToInfo *PTInfo = State->GetPointsToInfo();
  *Read = *Write = false;
  if (IsGemmIntrinsic(Inst))
    return;
  std::set<Value *> ReadPtrs, WritePtrs;
  if (IsHIVMIntrinsic(Inst)) {
    CallInst *Call = dyn_cast<CallInst>(Inst);
    if (Call->getCalledFunction()->getIntrinsicID() ==
        Intrinsic::hivm_SET_CMPMASK) {
      ReadPtrs.insert(Call->getArgOperand(0));
    } else {
      for (unsigned i = 0, n = Call->arg_size(); i < n; ++i) {
        Value *Arg = Call->getArgOperand(i);
        if (!Arg->getType()->isPointerTy() ||
            Arg->getType()->getPointerAddressSpace() != 6)
          continue;
        if (i == 0)
          WritePtrs.insert(Arg);
        else
          ReadPtrs.insert(Arg);
      }
    }
  } else if (LoadInst *Ld = dyn_cast<LoadInst>(Inst)) {
    ReadPtrs.insert(Ld->getPointerOperand());
  } else if (StoreInst *St = dyn_cast<StoreInst>(Inst)) {
    WritePtrs.insert(St->getPointerOperand());
  }

  for (Value *Ptr : ReadPtrs) {
    auto AliasObjs = PTInfo->GetPointsToObjsOfVal(Ptr, Inst);
    for (Value *Obj : AliasObjs) {
      if (UBObj == Obj) {
        *Read = true;
        break;
      }
    }
    if (*Read)
      break;
  }

  for (Value *Ptr : WritePtrs) {
    auto AliasObjs = PTInfo->GetPointsToObjsOfVal(Ptr, Inst);
    for (Value *Obj : AliasObjs) {
      if (UBObj == Obj) {
        *Write = true;
        break;
      }
    }
    if (*Write)
      break;
  }
}

bool GemmDMAInfo::HasWriteUBOperationInLoop(Loop *L, Value *UBMatrix) {
  static std::map<Loop *, bool> CachedResult;
  if (CachedResult.find(L) != CachedResult.end())
    return CachedResult[L];

  for (BasicBlock *BB : L->blocks()) {
    for (Instruction &Inst : *BB) {
      bool Read, Write;
      CheckReadOrWriteUBObject(&Inst, UBMatrix, &Read, &Write);
      if (Write) {
        CachedResult[L] = true;
        return true;
      }
    }
  }
  CachedResult[L] = false;
  return false;
}

Loop *GemmDMAInfo::GetOutestLoopForDMA(Instruction *Inst, bool *WriteUB) {
  Loop *InnerLoop = nullptr;
  Loop *OuterLoop = LI->getLoopFor(Inst->getParent());
  *WriteUB = false;
  while (OuterLoop) {
    if (!NoGemmInLoop(OuterLoop))
      return InnerLoop;
    BasicBlock *Pred = OuterLoop->getLoopPredecessor();
    SmallVector<BasicBlock *, 4> Succs;
    OuterLoop->getUniqueExitBlocks(Succs);
    if (!Pred || Succs.size() == 0)
      return InnerLoop;
    GemmStateDFValType EntryDFVal = State->GetBBExitResult(Pred);
    if (!EntryDFVal.Config.Valid)
      return InnerLoop;
    for (BasicBlock *Succ : Succs) {
      if (!DT->dominates(Pred, Succ)) {
        return InnerLoop;
      }
      GemmStateDFValType ExitDFVal = State->GetBBEntryResult(Succ);
      if (ExitDFVal != EntryDFVal)
        return InnerLoop;
    }
    *WriteUB = *WriteUB || HasWriteUBOperationInLoop(
                               OuterLoop, EntryDFVal.Config.GemmOutput);
    InnerLoop = OuterLoop;
    OuterLoop = OuterLoop->getParentLoop();
  }
  return InnerLoop;
}

void GemmDMAInfo::DoGemmDMAAnalysis() {
  PointsToInfo *PTInfo = State->GetPointsToInfo();
  std::set<Loop *> NoGemmLoops;
  for (BasicBlock &BB : *F) {
    // Compare dataflow fact at exit of predecessors and entry of current BB.
    // Gemms which are removed after merge should be stored from L0C to UB.
    GemmStateDFValType StateVal = State->GetBBEntryResult(&BB);
    for (BasicBlock *Pred : predecessors(&BB)) {
      GemmStateDFValType ExitStateVal = State->GetBBExitResult(Pred);
      if (ExitStateVal.Config.Valid && StateVal.Config != ExitStateVal.Config) {
        Res.Stores.insert(
            std::make_pair(Pred->getTerminator(), ExitStateVal.Config));
      } else if (!ExitStateVal.Config.Valid && StateVal.Config.Valid) {
        GemmLiveVarDFValType LVDFVal = LV->GetBBEntryResult(&BB);
        if (LVDFVal.find(StateVal.Config.GemmOutput) != LVDFVal.end())
          Res.Loads.insert(
              std::make_pair(Pred->getTerminator(), StateVal.Config));
      }
    }

    // Compare dataflow fact before and after each statement
    // Add load and store for gemm and use of gemm output(UB)
    GemmStateDFValType StateValAfter = StateVal;
    GemmConfig UBConfig;
    bool HasWriteOp = false;
    for (Instruction &Inst : BB) {
      State->GetVistor()->VisitInst(&Inst, StateValAfter);
      if (IsGemmIntrinsic(&Inst)) {
        bool NeedLoad = false, NeedStore = false;
        GemmConfig Config;
        bool InitC;
        GetHACLGemmConfig(&Inst, &Config, &InitC, PTInfo);
        if (Config != StateVal.Config) {
          if (StateVal.Config.Valid)
            NeedStore = true;
          if (!InitC)
            NeedLoad = true;
        } else if (UBConfig.Valid) {
          if (!InitC)
            NeedLoad = true;
          UBConfig.Valid = false;
        }
        if (NeedLoad)
          Res.Loads.insert(std::make_pair(&Inst, Config));
        if (NeedStore)
          Res.Stores.insert(std::make_pair(&Inst, StateVal.Config));
      } else if (StateVal.Config.Valid) {
        Loop *L = LI->getLoopFor(Inst.getParent());
        if (L) {
          if (NoGemmLoops.find(L) != NoGemmLoops.end()) {
            StateVal = StateValAfter;
            continue;
          }
        }

        bool Read, Write;
        CheckReadOrWriteUBObject(&Inst, StateVal.Config.GemmOutput, &Read,
                                 &Write);
        if (Read || Write) {
          if (!UBConfig.Valid) {
            bool WriteUB = false;
            if (Loop *L = GetOutestLoopForDMA(&Inst, &WriteUB)) {
              BasicBlock *Pred = L->getLoopPredecessor();
              SmallVector<BasicBlock *, 4> Succs;
              L->getUniqueExitBlocks(Succs);
              Res.Stores.insert(
                  std::make_pair(Pred->getTerminator(), StateVal.Config));
              if (WriteUB) {
                for (BasicBlock *Succ : Succs) {
                  GemmLiveVarDFValType LVDFVal = LV->GetBBEntryResult(Succ);
                  if (LVDFVal.find(StateVal.Config.GemmOutput) != LVDFVal.end())
                    Res.Loads.insert(
                        std::make_pair(&*Succ->begin(), StateVal.Config));
                }
              }
              NoGemmLoops.insert(L);
            } else {
              HasWriteOp = Write;
              UBConfig = StateVal.Config;
              Res.Stores.insert(std::make_pair(&Inst, StateVal.Config));
            }
          } else {
            HasWriteOp = HasWriteOp || Write;
          }
        }
      }
      StateVal = StateValAfter;
    }
    if (UBConfig.Valid && HasWriteOp) {
      GemmLiveVarDFValType LVDFVal =
          LV->GetInstResult(BB.getTerminator(), false);
      if (LVDFVal.find(UBConfig.GemmOutput) != LVDFVal.end())
        Res.Loads.insert(std::make_pair(BB.getTerminator(), UBConfig));
    }
  }
}