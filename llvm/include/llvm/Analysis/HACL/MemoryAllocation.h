/// Perform on-chip memory allocation

#ifndef LLVM_ANALYSIS_HACL_MEMORYALLOCATION_H
#define LLVM_ANALYSIS_HACL_MEMORYALLOCATION_H

#include "llvm/Analysis/HACL/LiveIntervalAnalysis.h"
#include "llvm/Analysis/HACL/MemoryUnitSelection.h"
#include "llvm/InitializePasses.h"
#include <set>
#include <map>

using namespace llvm;

namespace hacl {

typedef std::pair<MemoryUnit, std::pair<uint64_t, uint64_t>> AddressInfo;

/// MemoryAllocaResult - This class is the main on-chip memory allocation
/// driver.
class MemoryAllocaResult {
public:
  MemoryAllocaResult(Function *F, MemoryUnitInfo *MUI, IntervalInfo *II)
      : MUI(MUI), II(II), F(F) {
    doAllocation();
  }

  AddressInfo getAddressInfo(Instruction *Val) {
    auto it = AddressMap.find(Val);
    if (it == AddressMap.end()) {
      return std::make_pair(Undefined, std::make_pair(0, 0));
    }
    return it->second;
  }

  std::map<Instruction *, AddressInfo> &getAllAddressInfo() {
    return AddressMap;
  }

  void print(raw_ostream &);

private:
  /// Perform on-chip memory allocation.
  /// Result includes memory unit and address, and is saved in AddressMap.
  void doAllocation();

  /// Free allocated objects if its end point is less than the given point.
  void expireOldIntervals(unsigned, MemoryUnit);

  /// Allocate memory for one interval.
  void allocateInterval(Instruction *Val, unsigned End, MemoryUnit MU);

  MemoryUnitInfo *MUI;
  IntervalInfo *II;
  Function *F;

  /// Allocated memory in UB.
  /// The key is start address and value is length
  std::map<unsigned, unsigned> AllocatedUB;
  /// Allocated memory in L1.
  /// The key is start address and value is length
  std::map<unsigned, unsigned> AllocatedL1;
  /// Active objects in UB.
  /// The key means value to allocate memory.
  /// The value is a pair of unsigned value,
  /// the first means end point of the value's interval,
  /// the second means the start address of the value's memory.
  std::map<Instruction *, std::pair<unsigned, unsigned>> ActiveObjsUB;
  /// Active objects in L1.
  /// The key means value to allocate memory.
  /// The value is a pair of unsigned value,
  /// the first means end point of the value's interval,
  /// the second means the start address of the value's memory.
  std::map<Instruction *, std::pair<unsigned, unsigned>> ActiveObjsL1;
  /// The result of memory allocation.
  /// The key is object, the value includes memory unit and address.
  std::map<Instruction *, AddressInfo> AddressMap;
};

/// Legacy pass manager pass to perform memory allocation of Vector/Matrix
/// objects in a function
class HACLMemoryAllocation : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLMemoryAllocation() : FunctionPass(ID) {
    initializeHACLMemoryAllocationPass(*PassRegistry::getPassRegistry());
  }
  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &, const Module * = nullptr) const override;
  MemoryAllocaResult &getResult() const;

private:
  std::unique_ptr<MemoryAllocaResult> info;
}; // class HACLMemoryAllocation

} // end namespace hacl

namespace llvm {
/// createHACLMemoryAllocationPass - This creates an instance of the
/// HACLMemoryAllocation pass.
FunctionPass *createHACLMemoryAllocationPass();
} // namespace llvm

#endif