#include "llvm/Analysis/HACL/MemoryAllocation.h"
#include "llvm/IR/Constants.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLMemoryAllocation, "hacl-memalloc",
                      "HACL Memory Allocation Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(HACLMemoryUnitSelection)
INITIALIZE_PASS_DEPENDENCY(HACLLiveIntervalAnalysis)
INITIALIZE_PASS_END(HACLMemoryAllocation, "hacl-memalloc",
                    "HACL Memory Allocation Analysis", false, true)

char HACLMemoryAllocation::ID = 0;

FunctionPass *llvm::createHACLMemoryAllocationPass() {
  return new HACLMemoryAllocation();
}

void MemoryAllocaResult::doAllocation() {
  auto &Objs = II->GetResult();
  std::vector<std::pair<Instruction *, Interval>> SortedObjs;
  for (auto IT = Objs.begin(), IE = Objs.end(); IT != IE; ++IT) {
    SortedObjs.push_back(std::make_pair(IT->first, IT->second));
  }
  std::sort(SortedObjs.begin(), SortedObjs.end(),
            [](std::pair<Instruction *, Interval> a,
               std::pair<Instruction *, Interval> b) {
              return a.second.first < b.second.first;
            });
  for (auto IT = SortedObjs.begin(), IE = SortedObjs.end(); IT != IE; ++IT) {
    Instruction *Val = IT->first;
    unsigned Start = IT->second.first, End = IT->second.second;
    MemoryUnit MU = MUI->getMemoryUnit(Val);
    if (Start == 0 && End == 0) {
      AddressMap.insert({Val, {MU, {0, 0}}});
      continue;
    }
    expireOldIntervals(Start, MU);
    allocateInterval(Val, End, MU);
  }
}

void MemoryAllocaResult::allocateInterval(Instruction *Val, unsigned End,
                                          MemoryUnit MU) {
  unsigned UBL1Size = (MU == UB) ? 256 * 1024 : 1024 * 1024;
  unsigned Size = 0;
  if (ConstantInt *CI = dyn_cast<ConstantInt>(Val->getOperand(0))) {
    Size = CI->getZExtValue();
  }
  unsigned Addr = 0xFFFFFFFF;
  auto *Allocated = (MU == UB) ? &AllocatedUB : &AllocatedL1;
  auto *ActiveObjs = (MU == UB) ? &ActiveObjsUB : &ActiveObjsL1;
  if (Allocated->empty()) {
    Addr = 0;
  } else {
    auto IT = Allocated->begin(), Next = ++Allocated->begin();
    while (Next != Allocated->end()) {
      if (Next->first - IT->first - IT->second >= Size) {
        Addr = IT->first + IT->second;
        break;
      }
      ++IT;
      ++Next;
    }
    if (Size <= Allocated->begin()->first) {
      Addr = 0;
    } else if (IT->first + IT->second + Size <= UBL1Size) {
      Addr = IT->first + IT->second;
    }
  }
  if (Addr != 0xFFFFFFFF) {
    Allocated->insert({Addr, Size});
    ActiveObjs->insert({Val, {End, Addr}});
    AddressMap.insert({Val, {MU, {Addr, Size}}});
  } else if (Addr == 0xFFFFFFFF) {
    report_fatal_error("Unified buffer no enough space left.");
  }
}

void MemoryAllocaResult::expireOldIntervals(unsigned point, MemoryUnit MU) {
  auto *Allocated = (MU == UB) ? &AllocatedUB : &AllocatedL1;
  auto *ActiveObjs = (MU == UB) ? &ActiveObjsUB : &ActiveObjsL1;
  for (auto IT = ActiveObjs->begin(), IE = ActiveObjs->end(); IT != IE;) {
    if (IT->second.first < point) {
      Allocated->erase(IT->second.second);
      IT = ActiveObjs->erase(IT);
    } else {
      ++IT;
    }
  }
}

void MemoryAllocaResult::print(raw_ostream &Out) {
  Out << "-------Result of memory allocation-------\n";
  for (auto IT = AddressMap.begin(), IE = AddressMap.end(); IT != IE; ++IT) {
    Out << "Obj: " << *(IT->first) << ", MU: " << IT->second.first
        << ", Addr: " << IT->second.second.first
        << ", Size: " << IT->second.second.second << '\n';
  }
}

bool HACLMemoryAllocation::runOnFunction(Function &F) {
  auto &MUI = getAnalysis<HACLMemoryUnitSelection>().getResult();
  auto &II = getAnalysis<HACLLiveIntervalAnalysis>().getResult();
  info.reset(new MemoryAllocaResult(&F, &MUI, &II));
  return false;
}

void HACLMemoryAllocation::print(raw_ostream &Out, const Module *) const {
  info->print(Out);
}

MemoryAllocaResult &HACLMemoryAllocation::getResult() const { return *info; }

void HACLMemoryAllocation::releaseMemory() { info.reset(); }

void HACLMemoryAllocation::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<HACLMemoryUnitSelection>();
  AU.addRequiredTransitive<HACLLiveIntervalAnalysis>();
}