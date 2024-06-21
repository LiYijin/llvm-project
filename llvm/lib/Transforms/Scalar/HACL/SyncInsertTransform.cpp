#include "llvm/Transforms/Scalar/HACL/SyncInsertTransform.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicsHivm.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLSyncInsertTransform, "hacl-syncinserting",
                      "HACL Sync Inserting Transform", false, false)
INITIALIZE_PASS_DEPENDENCY(HACLRAWAnalysis)
INITIALIZE_PASS_DEPENDENCY(HACLWAWAnalysis)
INITIALIZE_PASS_DEPENDENCY(HACLWARAnalysis)
INITIALIZE_PASS_END(HACLSyncInsertTransform, "hacl-syncinserting",
                    "HACL Sync Inserting Transform", false, false)

char HACLSyncInsertTransform::ID = 0;

FunctionPass *llvm::createHACLSyncInsertTransformPass() {
  return new HACLSyncInsertTransform();
}

static Function *getIntrinsic(Function &F, Intrinsic::ID IID,
                              ArrayRef<Type *> Tys = std::nullopt) {
  return Intrinsic::getDeclaration(F.getParent(), (Intrinsic::ID)IID, Tys);
}

std::map<Instruction *, std::set<Instruction *>>
HACLSyncInsertTransform::collectDeps(DepType &RAW, DepType &WAR, DepType &WAW) {
  std::map<Instruction *, std::set<Instruction *>> Res;
  for (auto it = RAW.begin(), ie = RAW.end(); it != ie; ++it) {
    Res[it->first].insert(it->second);
  }
  for (auto it = WAR.begin(), ie = WAR.end(); it != ie; ++it) {
    Res[it->first].insert(it->second);
  }
  for (auto it = WAW.begin(), ie = WAW.end(); it != ie; ++it) {
    Res[it->first].insert(it->second);
  }

  return Res;
}

EventIDType HACLSyncInsertTransform::mergeEventIDForPredecessors(
    BasicBlock *BB, std::map<BasicBlock *, EventIDType> &BB_EventID) {
  EventIDType Res;

  // Merge result of predecessors
  for (BasicBlock *Pred : predecessors(BB)) {
    auto Found = BB_EventID.find(Pred);
    if (Found == BB_EventID.end())
      continue;
    auto PrevEventID = Found->second;
    for (auto IT = PrevEventID.begin(), IE = PrevEventID.end(); IT != IE;
         ++IT) {
      Res[IT->first] = std::max(Res[IT->first], IT->second);
    }
  }
  return Res;
}

bool HACLSyncInsertTransform::runOnFunction(Function &F) {
  // llvm::errs() << "HACLSyncInsertTransform::runOnFunction: before execute: \n";
  // llvm::errs() << F << "\n";
  // llvm::errs() << "HACLSyncInsertTransform::runOnFunction: before execute: end\n";
  auto &RAW = getAnalysis<HACLRAWAnalysis>().getResult();
  auto &WAR = getAnalysis<HACLWARAnalysis>().getResult();
  auto &WAW = getAnalysis<HACLWAWAnalysis>().getResult();

  std::map<Instruction *, std::set<Instruction *>> Deps =
      collectDeps(RAW.GetRAWPairs(), WAR.GetWARPairs(), WAW.GetWAWPairs());
  std::map<BasicBlock *, EventIDType> BB_EventID;

  // Get sync functions
  Function *SetFlag = getIntrinsic(F, Intrinsic::hivm_SET_FLAG_IMM);
  Function *WaitFlag = getIntrinsic(F, Intrinsic::hivm_WAIT_FLAG_IMM);
  Function *Barrier = getIntrinsic(F, Intrinsic::hivm_BARRIER);

  // Get IRBuilder
  IRBuilder<> Builder(F.getContext());

  // Int64Ty
  IntegerType *I64Ty = IntegerType::getInt64Ty(F.getContext());

  ReversePostOrderTraversal<Function *> RPOT(&F);
  for (auto RI = RPOT.begin(), RE = RPOT.end(); RI != RE; ++RI) {
    BasicBlock *BB = *RI;
    auto EventID = mergeEventIDForPredecessors(BB, BB_EventID);
    for (Instruction &Src : *BB) {
      auto Found = Deps.find(&Src);
      if (Found == Deps.end())
        continue;

      // Get pipe of src and dst
      pipe_t SrcPipe = GetPipeType(&Src);
      std::set<Instruction *> Dsts = Found->second;
      std::set<pipe_t> DstPipes;
      for (Instruction *Dst : Dsts) {
        pipe_t DstPipe = IsGemmIntrinsic(Dst) ? PIPE_LSU1 : GetPipeType(Dst);
        if (SrcPipe == PIPE_V && IsGemmIntrinsic(Dst))
          DstPipe = PIPE_M;
        DstPipes.insert(DstPipe);
      }

      // Insert sync instructions
      for (pipe_t DstPipe : DstPipes) {
        if (SrcPipe == DstPipe) {
          // Same pipeline, emit barrier
          Value *PipeVal = ConstantInt::get(I64Ty, SrcPipe);
          Instruction *I = Builder.CreateCall(Barrier, PipeVal, "");
          I->insertAfter(&Src);
        } else {
          // Different pipeline, emit set_flag/wait_flag
          Value *SrcPipeVal = ConstantInt::get(I64Ty, SrcPipe);
          Value *DstPipeVal = ConstantInt::get(I64Ty, DstPipe);
          Value *EventIDVal = ConstantInt::get(
              I64Ty, EventID[std::make_pair(SrcPipe, DstPipe)]);
          SmallVector<Value *, 3> Ops = {SrcPipeVal, DstPipeVal, EventIDVal};
          Instruction *Prev = &Src;
          Instruction *Cur = Builder.CreateCall(SetFlag, Ops, "");
          Cur->insertAfter(Prev);
          Prev = Cur;

          Cur = Builder.CreateCall(WaitFlag, Ops, "");
          Cur->insertAfter(Prev);
          Prev = Cur;

          // Update EventID, when used up, insert a reverse flag pair.
          if (++EventID[std::make_pair(SrcPipe, DstPipe)] == 4) {
            EventID[std::make_pair(SrcPipe, DstPipe)] = 0;
            Value *ReverseEventID = ConstantInt::get(
                I64Ty, EventID[std::make_pair(DstPipe, SrcPipe)]);
            SmallVector<Value *, 3> Ops1 = {DstPipeVal, SrcPipeVal,
                                            ReverseEventID};
            Cur = Builder.CreateCall(SetFlag, Ops1, "");
            Cur->insertAfter(Prev);
            Prev = Cur;

            Cur = Builder.CreateCall(WaitFlag, Ops1, "");
            Cur->insertAfter(Prev);
            Prev = Cur;

            if (++EventID[std::make_pair(DstPipe, SrcPipe)] == 4) {
              Ops[2] = ConstantInt::get(I64Ty, 0);
              Cur = Builder.CreateCall(SetFlag, Ops, "");
              Cur->insertAfter(Prev);
              Prev = Cur;

              Cur = Builder.CreateCall(WaitFlag, Ops, "");
              Cur->insertAfter(Prev);
              Prev = Cur;

              EventID[std::make_pair(DstPipe, SrcPipe)] = 0;
              ++EventID[std::make_pair(SrcPipe, DstPipe)];
            }
          }
        }
      }
    }
    BB_EventID[BB] = EventID;
  }
  // llvm::errs() << "HACLSyncInsertTransform::runOnFunction: after execute: \n";
  // llvm::errs() << F << "\n";
  // llvm::errs() << "HACLSyncInsertTransform::runOnFunction: after execute: end\n";
  return true;
}

void HACLSyncInsertTransform::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesCFG();
  AU.addRequiredTransitive<HACLRAWAnalysis>();
  AU.addRequiredTransitive<HACLWAWAnalysis>();
  AU.addRequiredTransitive<HACLWARAnalysis>();
}