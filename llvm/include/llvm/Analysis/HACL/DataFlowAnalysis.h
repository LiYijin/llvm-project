/// General data flow analysis framework

#ifndef LLVM_ANALYSIS_HACL_DATAFLOWANALYSIS_H
#define LLVM_ANALYSIS_HACL_DATAFLOWANALYSIS_H

#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/InstIterator.h"
#include <llvm/ADT/PostOrderIterator.h>
#include <queue>
#include <map>

using namespace llvm;

namespace hacl {

template <class T> class DataFlowEngine;

/// Base dataflow visitor class
template <class T> class DataFlowVisitor {
  friend class DataFlowEngine<T>;

public:
  DataFlowVisitor<T>() {}
  virtual ~DataFlowVisitor() {}

  /// Visitor method invoked at the start of each basic block with the entry
  /// parameters
  bool VisitBlock(BasicBlock *BB, T &Params, bool IsForward);

  /// Transfer function for each instruction
  virtual bool VisitInst(Instruction *Inst, T &Params) = 0;

  /// Merge of two dataflow facts
  virtual bool Merge(T &Dst, const T &Src) = 0;
};

/// Base dataflow analysis engine.
/// T defines type of dataflow fact.
/// Visitor defines transfer/merge function.
template <class T> class DataFlowEngine {
  Function *Func;
  DataFlowVisitor<T> *Visitor;
  std::map<BasicBlock *, std::pair<T, T>>
      BBResult; /// The dataflow result at every basicblock entry/exit

  /// Method to be done at the entry of the block.
  /// For forward dataflow analysis, the default implementation is to
  /// merge together the result from all incoming edges.
  /// The table BBResult may be updated
  bool EnterBasicBlock(BasicBlock *BB, bool IsForward);

  /// Method to be done at the exit of the block.
  /// For forward dataflow analysis, the default implementation is
  /// to push the basicblocks to the worklist to be updated.
  void LeaveBasicBlock(BasicBlock *BB, bool IsForward,
                       std::queue<BasicBlock *> *WorkList);

  /// Compute data flow fixed point
  void ComputeFixedPoint(std::queue<BasicBlock *> &WorkList, bool IsForward);
  void ComputeForwardFixedPoint(std::queue<BasicBlock *> &WorkList) {
    ComputeFixedPoint(WorkList, true);
  }
  void ComputeBackwardFixedPoint(std::queue<BasicBlock *> &WorkList) {
    ComputeFixedPoint(WorkList, false);
  }

public:
  DataFlowEngine(const DataFlowEngine<T> &Engine)
      : Func(Engine.Func), Visitor(Engine.Visitor), BBResult(Engine.BBResult) {}
  DataFlowEngine(Function *Func, DataFlowVisitor<T> *Visitor)
      : Func(Func), Visitor(Visitor), BBResult() {}
  virtual ~DataFlowEngine() {
    Func = nullptr;
    Visitor = nullptr;
    BBResult.clear();
  }

  DataFlowVisitor<T> *GetVistor() { return Visitor; }
  Function *GetFunction() { return Func; }

  void InitializeEntryResult(const T &Param);
  void InitializeExitResult(const T &Param);

  void reset() { BBResult.clear(); }

  T GetBBEntryResult(BasicBlock *BB);
  T GetBBExitResult(BasicBlock *BB);
  T GetInstResult(Instruction *Inst, bool IsForward);
  T GetResultAfterInst(Instruction *Inst, bool IsForward);

  void ComputeForwardDataFlow();
  void ComputeBackwardDataFlow();
};

template <class T>
bool DataFlowVisitor<T>::VisitBlock(BasicBlock *BB, T &Params, bool IsForward) {
  T tmp = Params;
  bool Ret = false;
  if (IsForward) {
    for (auto It = BB->begin(), Ie = BB->end(); It != Ie; ++It) {
      Instruction *Inst = &*It;
      Ret |= VisitInst(Inst, Params);
    }
  } else {
    for (auto It = BB->rbegin(), Ie = BB->rend(); It != Ie; ++It) {
      Instruction *Inst = &*It;
      Ret |= VisitInst(Inst, Params);
    }
  }
  return Ret;
}

template <class T>
bool DataFlowEngine<T>::EnterBasicBlock(BasicBlock *BB, bool IsForward) {
  T Result;

  if (IsForward) {
    for (BasicBlock *Pred : predecessors(BB)) {
      if (BBResult.find(Pred) != BBResult.end())
        Visitor->Merge(Result, BBResult[Pred].second);
    }
    return Visitor->Merge(BBResult[BB].first, Result);
  } else {
    for (BasicBlock *Succ : successors(BB)) {
      if (BBResult.find(Succ) != BBResult.end())
        Visitor->Merge(Result, BBResult[Succ].first);
    }
    return Visitor->Merge(BBResult[BB].second, Result);
  }
}

template <class T>
void DataFlowEngine<T>::LeaveBasicBlock(BasicBlock *BB, bool IsForward,
                                        std::queue<BasicBlock *> *WorkList) {
  if (IsForward) {
    for (BasicBlock *Succ : successors(BB)) {
      WorkList->push(Succ);
    }
  } else {
    for (BasicBlock *Pred : predecessors(BB)) {
      WorkList->push(Pred);
    }
  }
}

template <class T>
void DataFlowEngine<T>::ComputeFixedPoint(std::queue<BasicBlock *> &WorkList,
                                          bool IsForward) {
  while (!WorkList.empty()) {
    BasicBlock *BB = WorkList.front();
    WorkList.pop();

    bool Changed = false;
    if (BBResult.find(BB) == BBResult.end())
      Changed = true;
    if ((IsForward && BB == &Func->getEntryBlock()) ||
        (!IsForward && isa<ReturnInst>(BB->getTerminator())))
      Changed = true;
    Changed |= EnterBasicBlock(BB, IsForward);
    if (!Changed)
      continue;

    if (IsForward) {
      T Param = GetBBEntryResult(BB);
      Visitor->VisitBlock(BB, Param, IsForward);
      BBResult[BB].second = Param;
      LeaveBasicBlock(BB, IsForward, &WorkList);
    } else {
      T Param = GetBBExitResult(BB);
      Visitor->VisitBlock(BB, Param, IsForward);
      BBResult[BB].first = Param;
      LeaveBasicBlock(BB, IsForward, &WorkList);
    }
  }
}

template <class T>
void DataFlowEngine<T>::InitializeEntryResult(const T &Param) {
  T tmp;
  std::pair<T, T> DFVal = std::make_pair(Param, tmp);
  BasicBlock *Entry = &Func->getEntryBlock();
  BBResult.insert(std::make_pair(Entry, DFVal));
}

template <class T>
void DataFlowEngine<T>::InitializeExitResult(const T &Param) {
  T tmp;
  std::pair<T, T> DFVal = std::make_pair(tmp, Param);
  for (auto it = Func->begin(), ie = Func->end(); it != ie; ++it) {
    BasicBlock *BB = &*it;
    if (isa<ReturnInst>(BB->getTerminator()))
      BBResult.insert(std::make_pair(BB, DFVal));
  }
}

template <class T> T DataFlowEngine<T>::GetBBEntryResult(BasicBlock *BB) {
  auto result = BBResult.find(BB);
  if (result == BBResult.end()) {
    T tmp;
    return tmp;
  }
  return result->second.first;
}

template <class T> T DataFlowEngine<T>::GetBBExitResult(BasicBlock *BB) {
  auto result = BBResult.find(BB);
  if (result == BBResult.end()) {
    T tmp;
    return tmp;
  }
  return result->second.second;
}

template <class T>
T DataFlowEngine<T>::GetInstResult(Instruction *Inst, bool IsForward) {
  BasicBlock *BB = Inst->getParent();
  T Param;
  if (IsForward) {
    Param = GetBBEntryResult(BB);
    for (auto it = BB->begin(), ie = BB->end(); it != ie; ++it) {
      Instruction *I = &*it;
      if (I == Inst)
        break;
      Visitor->VisitInst(I, Param);
    }
  } else {
    Param = GetBBExitResult(BB);
    for (auto it = BB->rbegin(), ie = BB->rend(); it != ie; ++it) {
      Instruction *I = &*it;
      if (I == Inst)
        break;
      Visitor->VisitInst(I, Param);
    }
  }
  return Param;
}

template <class T>
T DataFlowEngine<T>::GetResultAfterInst(Instruction *Inst, bool IsForward) {
  BasicBlock *BB = Inst->getParent();
  T Param;
  if (IsForward) {
    Param = GetBBEntryResult(BB);
    for (auto it = BB->begin(), ie = BB->end(); it != ie; ++it) {
      Instruction *I = &*it;
      Visitor->VisitInst(I, Param);
      if (I == Inst)
        break;
    }
  } else {
    Param = GetBBExitResult(BB);
    for (auto it = BB->rbegin(), ie = BB->rend(); it != ie; ++it) {
      Instruction *I = &*it;
      Visitor->VisitInst(I, Param);
      if (I == Inst)
        break;
    }
  }
  return Param;
}

template <class T> void DataFlowEngine<T>::ComputeForwardDataFlow() {
  std::queue<BasicBlock *> WorkList;
  WorkList.push(&Func->getEntryBlock());
  ComputeForwardFixedPoint(WorkList);
}

template <class T> void DataFlowEngine<T>::ComputeBackwardDataFlow() {
  std::queue<BasicBlock *> WorkList;
  for (auto it = Func->begin(), ie = Func->end(); it != ie; ++it) {
    BasicBlock *BB = &*it;
    if (isa<ReturnInst>(BB->getTerminator()))
      WorkList.push(BB);
  }
  ComputeBackwardFixedPoint(WorkList);
}
} // namespace hacl

#endif