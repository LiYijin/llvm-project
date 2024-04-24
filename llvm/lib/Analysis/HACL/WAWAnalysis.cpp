#include "llvm/Analysis/HACL/WAWAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLWAWAnalysis, "hacl-waw",
                      "HACL Write-after-write Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLReachDefinitionAnalysis)
INITIALIZE_PASS_END(HACLWAWAnalysis, "hacl-waw",
                    "HACL Write-after-write Analysis", false, true)

char HACLWAWAnalysis::ID = 0;

FunctionPass *llvm::createHACLWAWAnalysisPass() {
  return new HACLWAWAnalysis();
}

void WAWInfo::CollectWAWPairs() {
  Function *F = RDInfo->GetFunction();
  for (Instruction &Inst : instructions(F)) {
    pipe_t PipeDst = GetPipeType(&Inst);
    ReachDefDFValType ReachDefsPrev = RDInfo->GetInstResult(&Inst, true);
    ReachDefDFValType ReachDefsAfter = RDInfo->GetResultAfterInst(&Inst, true);
    for (auto it = ReachDefsPrev.ReachDefs.begin(),
              ie = ReachDefsPrev.ReachDefs.end();
         it != ie; ++it) {
      for (auto it1 = it->second.begin(), ie1 = it->second.end(); it1 != ie1;
           ++it1) {
        if (ReachDefsAfter.ReachDefs[it->first].find(*it1) ==
            ReachDefsAfter.ReachDefs[it->first].end()) {
          pipe_t PipeSrc = GetPipeType(*it1);
          if (PipeSrc == PIPE_S && PipeDst == PIPE_S)
            continue;
          WAWPairs.insert(std::make_pair(*it1, &Inst));
        }
      }
    }
  }
}

void WAWInfo::print(raw_ostream &Out) {
  Out << "---------Result Of Write-after-write Analysis---------\n";
  for (auto it = WAWPairs.begin(), ie = WAWPairs.end(); it != ie; ++it) {
    llvm::errs() << "Src: " << *(it->first) << ", Dst: " << *(it->second)
                 << '\n';
  }
}

void HACLWAWAnalysis::print(raw_ostream &Out, const Module *Module) const {
  info->print(Out);
}

bool HACLWAWAnalysis::runOnFunction(Function &F) {
  auto &RDInfo = getAnalysis<HACLReachDefinitionAnalysis>().getResult();
  WAWInfo *Result = new WAWInfo(&RDInfo);
  Result->CollectWAWPairs();
  info.reset(Result);
  return false;
}

WAWInfo &HACLWAWAnalysis::getResult() const { return *info; }

void HACLWAWAnalysis::releaseMemory() { info.reset(); }

void HACLWAWAnalysis::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLReachDefinitionAnalysis>();
}