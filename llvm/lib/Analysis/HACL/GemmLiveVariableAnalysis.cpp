#include "llvm/Analysis/HACL/GemmLiveVariableAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLGemmLiveVariableAnalysis, "hacl-gemmlv",
                      "HACL Gemm Live Variable Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLBasicPointsToAnalysis)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass)
INITIALIZE_PASS_END(HACLGemmLiveVariableAnalysis, "hacl-gemmlv",
                    "HACL Gemm Live Variable Analysis", false, true)

char HACLGemmLiveVariableAnalysis::ID = 0;

FunctionPass *llvm::createHACLGemmLiveVariableAnalysisPass() {
  return new HACLGemmLiveVariableAnalysis();
}

static Value *StripCast(Value *Val) {
  while (CastInst *Cast = dyn_cast<CastInst>(Val)) {
    Val = Cast->getOperand(0);
  }
  return Val;
}

bool GemmLiveVariableDFVisitor::VisitInst(Instruction *Inst,
                                          GemmLiveVarDFValType &Param) {
  bool Ret = false;

  if (Param.find(Inst) != Param.end())
    return Param.erase(Inst);

  if (IsGemmIntrinsic(Inst)) {
    uint64_t Config =
        dyn_cast<ConstantInt>(Inst->getOperand(3))->getZExtValue();
    // Check init_c bit, only consider accumulate case
    if (Config >> 63)
      return false;
    BasicBlock *BB = Inst->getParent();
    BasicBlock *Pred = BB->getUniquePredecessor();
    Loop *L = LI->getLoopFor(Inst->getParent());
    bool InitValIsNeeded = true;
    if (Pred && L) {
      BranchInst *Terminator = dyn_cast<BranchInst>(Pred->getTerminator());
      if (Terminator && Terminator->isConditional()) {
        if (ICmpInst *Cmp = dyn_cast<ICmpInst>(Terminator->getCondition())) {
          Value *Op0 = Cmp->getOperand(0), *Op1 = Cmp->getOperand(1);
          const SCEV *LHS = SE->getSCEV(StripCast(Op0)),
                     *RHS = SE->getSCEV(StripCast(Op1));
          CmpInst::Predicate Pred = Cmp->getPredicate();
          if (Terminator->getOperand(1) == BB)
            Pred = CmpInst::getInversePredicate(Pred);
          if (const SCEVAddRecExpr *AddRec = dyn_cast<SCEVAddRecExpr>(RHS)) {
            if (AddRec->getLoop() == L) {
              std::swap(Op0, Op1);
              std::swap(LHS, RHS);
              Pred = CmpInst::getSwappedPredicate(Pred);
            }
          }
          if (const SCEVAddRecExpr *AddRec = dyn_cast<SCEVAddRecExpr>(LHS)) {
            if (AddRec->getLoop() == L) {
              const SCEV *Start = AddRec->getStart();
              if (isa<SCEVUnknown>(Start) || isa<SCEVConstant>(Start)) {
                Value *StartVal = nullptr;
                if (const SCEVUnknown *Tmp = dyn_cast<SCEVUnknown>(Start)) {
                  StartVal = Tmp->getValue();
                } else if (const SCEVConstant *Tmp =
                               dyn_cast<SCEVConstant>(Start)) {
                  StartVal = Tmp->getValue();
                }
                if (StartVal == Op1) {
                  if (Pred == CmpInst::Predicate::ICMP_NE ||
                      Pred == CmpInst::Predicate::ICMP_UGT ||
                      Pred == CmpInst::Predicate::ICMP_ULT ||
                      Pred == CmpInst::Predicate::ICMP_SGT ||
                      Pred == CmpInst::Predicate::ICMP_SLT) {
                    InitValIsNeeded = false;
                  }
                }
              }
            }
          }
        }
      }
    }
    if (InitValIsNeeded) {
      auto AliasObjs = PTInfo->GetPointsToObjsOfVal(Inst->getOperand(0), Inst);
      for (Value *Obj : AliasObjs) {
        Ret |= Param.insert(Obj).second;
      }
    }
  }
  return Ret;
}

bool GemmLiveVariableDFVisitor::Merge(GemmLiveVarDFValType &Dst,
                                      const GemmLiveVarDFValType &Src) {
  bool Ret = false;
  for (auto it = Src.begin(), ie = Src.end(); it != ie; ++it) {
    Ret |= Dst.insert(*it).second;
  }
  return Ret;
}

void GemmLiveVariableInfo::Initialize() {
  GemmLiveVarDFValType tmp;
  InitializeExitResult(tmp);
}

void GemmLiveVariableInfo::print(raw_ostream &Out) {
  Function *F = GetFunction();
  Out << "---------Result Of Gemm Live Variable Analysis---------\n";
  Out << *F << '\n';
  for (auto IT = F->begin(), IE = F->end(); IT != IE; ++IT) {
    BasicBlock *BB = &*IT;
    GemmLiveVarDFValType DFVal = GetBBEntryResult(BB);
    Out << "BB entry result: " << BB->front() << '\n';
    for (auto it = DFVal.begin(), ie = DFVal.end(); it != ie; ++it) {
      Out << **it << '\n';
    }
    GemmLiveVarDFValType DFVal1 = GetBBExitResult(BB);
    Out << "BB exit result: " << BB->front() << '\n';
    for (auto it = DFVal1.begin(), ie = DFVal1.end(); it != ie; ++it) {
      Out << **it << '\n';
    }
  }
  Out << "---------End Of Gemm Live Variable Analysis---------\n";
}

void HACLGemmLiveVariableAnalysis::print(raw_ostream &Out,
                                         const Module *Module) const {
  info->print(Out);
}

bool HACLGemmLiveVariableAnalysis::runOnFunction(Function &F) {
  auto &PTInfo = getAnalysis<HACLBasicPointsToAnalysis>().getResult();
  auto &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
  auto &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();
  GemmLiveVariableInfo *Result =
      new GemmLiveVariableInfo(&F, &PTInfo, &LI, &SE);
  Result->ComputeBackwardDataFlow();
  info.reset(Result);
  return false;
}

GemmLiveVariableInfo &HACLGemmLiveVariableAnalysis::getResult() const {
  return *info;
}

void HACLGemmLiveVariableAnalysis::releaseMemory() { info.reset(); }

void HACLGemmLiveVariableAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLBasicPointsToAnalysis>();
  AU.addRequiredTransitive<LoopInfoWrapperPass>();
  AU.addRequiredTransitive<ScalarEvolutionWrapperPass>();
}