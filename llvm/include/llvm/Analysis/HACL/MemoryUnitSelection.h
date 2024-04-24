/// Select on-chip memory unit according to use info

#ifndef LLVM_ANALYSIS_HACL_MEMORYUNITSELECTION_H
#define LLVM_ANALYSIS_HACL_MEMORYUNITSELECTION_H

#include <llvm/IR/Value.h>
#include <llvm/IR/PassManager.h>
#include <set>
#include <map>
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

using namespace llvm;

namespace hacl {

enum MemoryUnit { L1 = 2, L0A, L0B, L0C, UB, Undefined };

/// MemoryUnitInfo - This class is the main on-chip memory unit select driver.
class MemoryUnitInfo {
public:
  MemoryUnitInfo(Function *F) : F(F) { doAnalysis(); }

  std::set<Value *> &getAllObjects() { return Objects; }
  MemoryUnit getMemoryUnit(Value *Val) {
    auto it = ObjMemUnitMap.find(Val);
    if (it == ObjMemUnitMap.end()) {
      return Undefined;
    }
    return it->second;
  }
  void print(raw_ostream &out);

private:
  /// Select memory unit according to use info.
  /// The set of objects will be written in Objects.
  /// The result of memory unit selection will be writtern in ObjMemUnitMap.
  void doAnalysis();

  Function *F;
  std::set<Value *> Objects;
  std::map<Value *, MemoryUnit> ObjMemUnitMap;
};

/// Legacy pass manager pass to select memory unit of Vector/Matrix objects in a
/// function
class HACLMemoryUnitSelection : public FunctionPass {
public:
  static char ID; // Class identification, replacement for typeinfo
  HACLMemoryUnitSelection() : FunctionPass(ID) {
    initializeHACLMemoryUnitSelectionPass(*PassRegistry::getPassRegistry());
  }

  bool runOnFunction(Function &F) override;
  void releaseMemory() override;
  void getAnalysisUsage(AnalysisUsage &) const override;
  void print(raw_ostream &Out, const Module * = nullptr) const override {
    info->print(Out);
  }
  MemoryUnitInfo &getResult() const;

private:
  std::unique_ptr<MemoryUnitInfo> info;
}; // class HACLMemoryUnitSelection

} // end namespace hacl

namespace llvm {
/// createHACLMemoryUnitSelectionPass - This creates an instance of the
/// HACLMemoryUnitSelection pass.
FunctionPass *createHACLMemoryUnitSelectionPass();
} // namespace llvm

#endif