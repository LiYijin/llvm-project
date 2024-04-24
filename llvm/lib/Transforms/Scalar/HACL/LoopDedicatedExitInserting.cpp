#include "llvm/Transforms/Scalar/HACL/LoopDedicatedExitInserting.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Analysis/LoopInfo.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(LoopDedicatedExitInserting, "hacl-loopexitinserting",
                      "Insert loop dedicated exit", false, false)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_END(LoopDedicatedExitInserting, "hacl-loopexitinserting",
                    "Insert loop dedicated exit", false, false)

char LoopDedicatedExitInserting::ID = 0;

FunctionPass *llvm::createLoopDedicatedExitInsertingPass() {
  return new LoopDedicatedExitInserting();
}

bool LoopDedicatedExitInserting::runOnFunction(Function &F) {
  llvm::errs() << "LoopDedicatedExitInserting::runOnFunction: before execute: \n";
  llvm::errs() << F << "\n";
  llvm::errs() << "LoopDedicatedExitInserting::runOnFunction: before execute: end\n";

  auto &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
  auto &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();

  std::set<Loop *> Visited, NoDedicatedExitLoops;
  for (BasicBlock &BB : F) {
    Loop *L = LI.getLoopFor(&BB);
    if (!L || Visited.find(L) != Visited.end())
      continue;
    Visited.insert(L);
    if (!L->hasDedicatedExits())
      NoDedicatedExitLoops.insert(L);
  }
  for (Loop *L : NoDedicatedExitLoops) {
    formDedicatedExitBlocks(L, &DT, &LI, nullptr, false);
  }

  llvm::errs() << "LoopDedicatedExitInserting::runOnFunction: after execute: \n";
  llvm::errs() << F << "\n";
  llvm::errs() << "LoopDedicatedExitInserting::runOnFunction: after execute: end\n";
  return NoDedicatedExitLoops.size();
}

void LoopDedicatedExitInserting::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequiredTransitive<LoopInfoWrapperPass>();
  AU.addRequiredTransitive<DominatorTreeWrapperPass>();
}