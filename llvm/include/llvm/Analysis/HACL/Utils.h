#ifndef LLVM_ANALYSIS_HACL_UTILS_H
#define LLVM_ANALYSIS_HACL_UTILS_H

#include "llvm/IR/Instructions.h"
#include <set>

using namespace llvm;

typedef enum {
  PIPE_S = 0,
  PIPE_V,
  PIPE_M,
  PIPE_LSU1,
  PIPE_LSU2,
  PIPE_LSU3,
  PIPE_ALL,
  PIPE_NONE
} pipe_t;

/// Data used to determine read & write operation introduced by
/// vec_trans_scatter
typedef struct {
  std::set<Value *> Srcs;
  std::set<Value *> Dsts;
} VAStatus;

bool IsHIVMIntrinsic(const llvm::Instruction *Inst);
bool IsGemmIntrinsic(const llvm::Instruction *Inst);
std::set<llvm::Instruction *> CollectObjects(llvm::Function *Func);
pipe_t GetPipeType(const llvm::Instruction *Inst);
bool GetVAStatus(CallInst *Inst, VAStatus *Status);
std::set<Value *> GetAliasPointersForVA(Value *Val, Instruction *Pos);

#endif