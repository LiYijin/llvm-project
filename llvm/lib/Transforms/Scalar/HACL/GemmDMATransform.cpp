#include "llvm/Transforms/Scalar/HACL/GemmDMATransform.h"
#include "llvm/Analysis/HACL/GemmDMAAnalysis.h"
#include "llvm/Analysis/HACL/Utils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsHivm.h"
#include "llvm/IR/IntrinsicInst.h"

using namespace hacl;

INITIALIZE_PASS_BEGIN(HACLGemmDMATransform, "hacl-gemmdmatransform",
                      "HACL Gemm DMA Transform", false, false)
INITIALIZE_PASS_DEPENDENCY(HACLGemmDMAAnalysis)
INITIALIZE_PASS_END(HACLGemmDMATransform, "hacl-gemmdmatransform",
                    "HACL Gemm DMA Transform", false, false)

char HACLGemmDMATransform::ID = 0;

FunctionPass *llvm::createHACLGemmDMATransformPass() {
  return new HACLGemmDMATransform();
}

static Function *getIntrinsic(Function &F, Intrinsic::ID IID,
                              ArrayRef<Type *> Tys = std::nullopt) {
  return Intrinsic::getDeclaration(F.getParent(), (Intrinsic::ID)IID, Tys);
}

static int64_t GetDataMovConfig(uint16_t BurstNum, uint16_t BurstLen,
                                uint16_t SrcStride, uint16_t DstStride) {
  // Compute config value by BurstNum, BurstLen, DstStride, SrcStride
  const uint32_t POS_NBURST = 4;
  const uint32_t POS_LENBURST = 16;
  const uint32_t POS_SRCSTRIDE = 32;
  const uint32_t POS_DSTSTRIDE = 48;

  int64_t ret = 0;
  ret |= (uint64_t)BurstNum << POS_NBURST;
  ret |= (uint64_t)BurstLen << POS_LENBURST;
  ret |= (uint64_t)SrcStride << POS_SRCSTRIDE;
  ret |= (uint64_t)DstStride << POS_DSTSTRIDE;
  return ret;
}

bool HACLGemmDMATransform::runOnFunction(Function &F) {
  // llvm::errs() << "HACLGemmDMATransform::runOnFunction: before execute: \n";
  // llvm::errs() << F << "\n";
  // llvm::errs() << "HACLGemmDMATransform::runOnFunction: before execute: end\n";
  auto &Res = getAnalysis<HACLGemmDMAAnalysis>().getResult().GetResult();
  LLVMContext &Context = F.getContext();
  Function *L0CToUBF16 = getIntrinsic(F, Intrinsic::hivm_MOV_L0C32_TO_UB_f2h);
  Function *L0CToUBF32 = getIntrinsic(F, Intrinsic::hivm_MOV_L0C32_TO_UB_f32);
  Function *L0CToUBU32 = getIntrinsic(F, Intrinsic::hivm_MOV_L0C32_TO_UB_u32);
  Function *UBToL0CF16 = getIntrinsic(F, Intrinsic::hivm_MOV_UB_TO_L0C32_h2f);
  Function *UBToL0CF32 = getIntrinsic(F, Intrinsic::hivm_MOV_UB_TO_L0C32_f32);
  Function *UBToL0CU32 = getIntrinsic(F, Intrinsic::hivm_MOV_UB_TO_L0C32_u32);
  Function *GetIMM = getIntrinsic(F, Intrinsic::hivm_GET_IMM_16);

  IRBuilder<> Builder(Context);
  // Emit Address of L0C
  Builder.SetInsertPoint(&(F.getEntryBlock().front()));
  ConstantInt *Zero = ConstantInt::get(IntegerType::getInt64Ty(Context), 0);
  ConstantInt *One = ConstantInt::get(IntegerType::getInt64Ty(Context), 1);
  ConstantInt *Four = ConstantInt::get(IntegerType::getInt64Ty(Context), 4);
  Value *Addr0 = Builder.CreateCall(GetIMM, {Zero});
  Value *DstL0C = Builder.CreateIntToPtr(
      Addr0, PointerType::get(Builder.getInt8PtrTy(), 5));

  // Insert Stores
  for (auto IT = Res.Stores.begin(), IE = Res.Stores.end(); IT != IE; ++IT) {
    Instruction *Inst = &*(IT->first);
    Builder.SetInsertPoint(Inst);
    GemmConfig Config = IT->second;
    Value *MovConfig = ConstantInt::get(
        IntegerType::getInt64Ty(Context),
        GetDataMovConfig(1, Config.M * Config.N / 16 / 16, 0, 0));
    Value *Output = Builder.CreateBitCast(
        Config.GemmOutput, PointerType::get(Builder.getInt8PtrTy(), 6));
    Type *Ty = Config.OutputTy;
    Function *L0CToUB = nullptr;
    ConstantInt *Cast = Zero;  // no cast
    if (Ty->isHalfTy())
    {
      L0CToUB = L0CToUBF16;
      Cast = One;  // f32->f16
    }
    else if (Ty->isFloatTy())
      L0CToUB = L0CToUBF32;
    else
      L0CToUB = L0CToUBU32;
    SmallVector<Value *, 4> Args = {Output, DstL0C, MovConfig, Cast};
    Builder.CreateCall(L0CToUB, Args);
  }

  // Insert Loads
  for (auto IT = Res.Loads.begin(), IE = Res.Loads.end(); IT != IE; ++IT) {
    Instruction *Inst = &*(IT->first);
    Builder.SetInsertPoint(Inst);
    GemmConfig Config = IT->second;
    Value *MovConfig = ConstantInt::get(
        IntegerType::getInt64Ty(Context),
        GetDataMovConfig(1, Config.M * Config.N / 16 / 16, 0, 0));
    Value *Output = Builder.CreateBitCast(
        Config.GemmOutput, PointerType::get(Builder.getInt8PtrTy(), 6));
    Type *Ty = Config.OutputTy;
    Function *UBToL0C = nullptr;
    ConstantInt *Cast = Zero;  // no cast
    if (Ty->isHalfTy())
    {
      UBToL0C = UBToL0CF16;
      Cast = Four;  // f16->f32
    }
    else if (Ty->isFloatTy())
      UBToL0C = UBToL0CF32;
    else
      UBToL0C = UBToL0CU32;
    SmallVector<Value *, 4> Args = {DstL0C, Output, MovConfig, Cast};
    Builder.CreateCall(UBToL0C, Args);
  }

  for (Instruction &Inst : instructions(&F)) {
    if (IsGemmIntrinsic(&Inst)) {
      Builder.SetInsertPoint(&Inst);
      IntrinsicInst *GemmIntrinsicInst = dyn_cast<IntrinsicInst>(&Inst);
      if(!GemmIntrinsicInst) {
        llvm::errs() << "Error! GemmDMATransform.cpp: Inst is not an intrinsic instruction\n";
        exit(-1);
      }
      llvm::Intrinsic::ID gemmIntrinsicInstID = GemmIntrinsicInst->getIntrinsicID();
      Type *DstElementTy = nullptr;
      if(gemmIntrinsicInstID == llvm::Intrinsic::hivm_MAD_f162f16) {
        DstElementTy = Type::getHalfTy(GemmIntrinsicInst->getContext());
      } else if(gemmIntrinsicInstID == llvm::Intrinsic::hivm_MAD_f162f32) {
        DstElementTy = Type::getFloatTy(GemmIntrinsicInst->getContext());
      } else {
        DstElementTy = Type::getInt32Ty(GemmIntrinsicInst->getContext());
      }
      Type *DstTy = Inst.getOperand(0)->getType();
      Value *Dst = Builder.CreateBitCast(DstL0C, DstTy);
      if (DstElementTy->isHalfTy())
        Dst = Builder.CreateBitCast(
            DstL0C, PointerType::get(Type::getFloatTy(Context), 5));
      Inst.setOperand(0, Dst);
    }
  }
  // llvm::errs() << "HACLGemmDMATransform::runOnFunction: after execute: \n";
  // llvm::errs() << F << "\n";
  // llvm::errs() << "HACLGemmDMATransform::runOnFunction: after execute: end\n";
  return Res.Loads.size() || Res.Stores.size();
}

void HACLGemmDMATransform::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequiredTransitive<HACLGemmDMAAnalysis>();
  AU.setPreservesCFG();
}