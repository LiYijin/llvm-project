//===- IntrinsicsHIVM.td - Defines HIVM intrinsics ---------*- tablegen -*-===//
//
// Copyright (C) 2018. Huawei Technologies Co., Ltd. All rights reserved.
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the HIVM-specific intrinsics for use with HiIPU.
//
//===----------------------------------------------------------------------===//

//---------------------------------------------------------------------------//
// CCE address spaces are defined at HiIPUAddrSpaceMap@lib/Basic/Targets.cpp
//---------------------------------------------------------------------------//
def llvm_ptr_ty1 : LLVMQualPointerType<1>; // __gm__
def llvm_ptr_ty2 : LLVMQualPointerType<2>; // __cbuf__
def llvm_ptr_ty3 : LLVMQualPointerType<3>; // __ca__
def llvm_ptr_ty4 : LLVMQualPointerType<4>; // __cb__
def llvm_ptr_ty5 : LLVMQualPointerType<5>; // __cc__
def llvm_ptr_ty6 : LLVMQualPointerType<6>; // __ubuf__
def llvm_ptr_ty7 : LLVMQualPointerType<7>; // __fbuf__
def llvm_ptr_ty_any : LLVMAnyPointerType<>;

let TargetPrefix = "hivm" in {
  // GET IMM
  def int_hivm_GET_IMM_16 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty], [IntrNoMem]>;

  // GET Virtual Address
  def int_hivm_GET_ADDR : Intrinsic<[llvm_ptr_ty_any], [llvm_i64_ty, llvm_i64_ty], [IntrInaccessibleMemOnly]>;

  // SCALAR_ABS
  def int_hivm_ABS_s64 : Intrinsic<[llvm_i64_ty],[llvm_i64_ty],[IntrNoMem]>;
  def int_hivm_SQRT_f32 : Intrinsic<[llvm_float_ty], [llvm_float_ty], [IntrNoMem]>;

  // SCALAR_SQRT
  def int_hivm_SQRT_s64 : Intrinsic<[llvm_i64_ty],[llvm_i64_ty],[IntrNoMem]>; 

  // SCALAR_BCNT0
  def int_hivm_BCNT0 : Intrinsic<[llvm_i64_ty],[llvm_i64_ty],[IntrNoMem]>; 

  // SCALAR_BCNT1
  def int_hivm_BCNT1 : Intrinsic<[llvm_i64_ty],[llvm_i64_ty],[IntrNoMem]>; 

  // SCALAR_CLZ
  def int_hivm_CLZ : Intrinsic<[llvm_i64_ty],[llvm_i64_ty],[IntrNoMem]>; 

  // SCALAR_MIN
  def int_hivm_MIN_s64 : Intrinsic<[llvm_i64_ty],[llvm_i64_ty,llvm_i64_ty],[IntrNoMem]>;

  // SCALAR_MAX
  def int_hivm_MAX_s64 : Intrinsic<[llvm_i64_ty],[llvm_i64_ty,llvm_i64_ty],[IntrNoMem]>;

  // VADD
  def int_hivm_VADD_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VADD_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VADD_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VSUB
  def int_hivm_VSUB_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VSUB_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VSUB_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VMUL
  def int_hivm_VMUL_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMUL_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMUL_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VDIV
  def int_hivm_VDIV_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VDIV_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

 // VMIN
  def int_hivm_VMIN_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMIN_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMIN_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VMAX
  def int_hivm_VMAX_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMAX_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMAX_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VAND
  def int_hivm_VAND_s16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VAND_u16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VOR
  def int_hivm_VOR_s16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VOR_u16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VMADD
  def int_hivm_VMADD_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMADD_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VMADDRELU
  def int_hivm_VMADDRELU_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMADDRELU_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VMLA
  def int_hivm_VMLA_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VMLA_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VABS
  def int_hivm_VABS_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VABS_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;

  // VADDS
  def int_hivm_VADDS_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_float_ty, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VADDS_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_half_ty, llvm_i64_ty], [IntrArgMemOnly]>;

  // VMULS
  def int_hivm_VMULS_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_float_ty, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VMULS_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_half_ty, llvm_i64_ty], [IntrArgMemOnly]>;

  // VAXPY
  def int_hivm_VAXPY_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_float_ty, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VAXPY_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_half_ty, llvm_i64_ty], [IntrArgMemOnly]>;


  // VCADD
  def int_hivm_VCADD_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCADD_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // VCMAX
  def int_hivm_VCMAX_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // VCMIN
  def int_hivm_VCMIN_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // VCPADD
  def int_hivm_VCPADD_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // VRELU
  def int_hivm_VRELU_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  
  // VEXP
  def int_hivm_VEXP_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VEXP_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  
  // VREC
  def int_hivm_VREC_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VREC_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  
  // VLN
  def int_hivm_VLN_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VLN_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  
  // VRSQRT
  def int_hivm_VRSQRT_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VRSQRT_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;

  // VSQRT
  def int_hivm_VSQRT_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VSQRT_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;


  // VNOT
  def int_hivm_VNOT_s16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;
  def int_hivm_VNOT_u16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;

  // VCMPV.LT
  def int_hivm_VCMPV_LT_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VCMPV_LT_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VCMPV.LE
  def int_hivm_VCMPV_LE_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VCMPV_LE_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VCMPV.GT
  def int_hivm_VCMPV_GT_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VCMPV_GT_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VCMPV.GE
  def int_hivm_VCMPV_GE_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VCMPV_GE_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VCMPV.EQ
  def int_hivm_VCMPV_EQ_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VCMPV_EQ_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VCMPV.NE
  def int_hivm_VCMPV_NE_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VCMPV_NE_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // SET.CMPMASK
  def int_hivm_SET_CMPMASK : Intrinsic<[], [llvm_ptr_ty6], 
    [IntrInaccessibleMemOrArgMemOnly, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<0>>]>;

  // VSEL
  def int_hivm_VSEL_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_VSEL_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // VCONV
  def int_hivm_VCONV_f162s32r : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f162s32f : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f162s32c : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f322s32r : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f322s32f : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f322s32c : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_s322f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f162f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f322f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f162s8 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_f162u8 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_u82f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_s82f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_VCONV_DEQ : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  def int_hivm_SET_DEQSCALE_h : Intrinsic<[], [llvm_half_ty], [IntrInaccessibleMemOnly]>;

  // MOVEV
  def int_hivm_MOVEV_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_float_ty, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>]>;
  def int_hivm_MOVEV_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_half_ty, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>]>;
  def int_hivm_MOVEV_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>]>;
  def int_hivm_MOVEV_u32 : Intrinsic<[], [llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>]>;
  def int_hivm_MOVEV_s16 : Intrinsic<[], [llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>]>;
  def int_hivm_MOVEV_u16 : Intrinsic<[], [llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty], 
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>]>;

  // MOVEVA
  def int_hivm_MOVEVA : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrInaccessibleMemOnly]>;

  // VNCHWCONV
  def int_hivm_S_VNCHWCONV_b8 : Intrinsic<[],
    [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
    [IntrInaccessibleMemOnly]>;
  def int_hivm_S_VNCHWCONV_b16 : Intrinsic<[],
    [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
    [IntrInaccessibleMemOnly]>;
    
  // MAD
  def int_hivm_MAD_f162f32 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty3, llvm_ptr_ty4, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_MAD_f162f16 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty3, llvm_ptr_ty4, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_MAD_u8 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty3, llvm_ptr_ty4, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_MAD_s8 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty3, llvm_ptr_ty4, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;
  def int_hivm_MAD_u8s8 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty3, llvm_ptr_ty4, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<2>>, ReadOnly<ArgIndex<2>>]>;

  // MOVE UB TO UB
  def int_hivm_MOV_UB_TO_UB : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;

  // MOVE OUT TO UB
  def int_hivm_MOV_OUT_TO_UB : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty1, llvm_i64_ty], [IntrArgMemOnly]>;

  // MOVE UB TO OUT
  def int_hivm_MOV_UB_TO_OUT : Intrinsic<[], [llvm_ptr_ty1, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;

  // MOVE OUT TO L1
  def int_hivm_MOV_OUT_TO_L1 : Intrinsic<[], [llvm_ptr_ty2, llvm_ptr_ty1, llvm_i64_ty, llvm_i64_ty], [IntrArgMemOnly]>;

  // MOVE UB TO L1
  def int_hivm_MOV_UB_TO_L1 : Intrinsic<[], [llvm_ptr_ty2, llvm_ptr_ty6, llvm_i64_ty], [IntrArgMemOnly]>;

  // MOVE L1 TO UB
  def int_hivm_MOV_L1_TO_UB : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty2, llvm_i64_ty], [IntrArgMemOnly]>;

  // No real data move path for following intrinsics
  // MOVE L1 TO OUT
  def int_hivm_MOV_L1_TO_OUT : Intrinsic<[], [llvm_ptr_ty1, llvm_ptr_ty2, llvm_i64_ty], [IntrArgMemOnly]>;
  // MOVE L1 TO L1
  def int_hivm_MOV_L1_TO_L1 : Intrinsic<[], [llvm_ptr_ty2, llvm_ptr_ty2, llvm_i64_ty], [IntrArgMemOnly]>;

  // Load L1 To L0A
  def int_hivm_LOAD_L1_TO_L0A_2D_f16 : Intrinsic<[], [llvm_ptr_ty3, llvm_ptr_ty2, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_LOAD_L1_TO_L0A_2D_s8 : Intrinsic<[], [llvm_ptr_ty3, llvm_ptr_ty2, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_LOAD_L1_TO_L0A_2D_u8 : Intrinsic<[], [llvm_ptr_ty3, llvm_ptr_ty2, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // Load L1 To L0B
  def int_hivm_LOAD_L1_TO_L0B_2D_f16 : Intrinsic<[], [llvm_ptr_ty4, llvm_ptr_ty2, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_LOAD_L1_TO_L0B_2D_s8 : Intrinsic<[], [llvm_ptr_ty4, llvm_ptr_ty2, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_LOAD_L1_TO_L0B_2D_u8 : Intrinsic<[], [llvm_ptr_ty4, llvm_ptr_ty2, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // MOV L0C TO UB
  def int_hivm_MOV_L0C32_TO_UB_f32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty5, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_L0C16_TO_UB_f16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty5, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_L0C32_TO_UB_u32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty5, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_L0C32_TO_UB_s32 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty5, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_L0C32_TO_UB_f2h : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty5, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // MOV UB TO L0C
  def int_hivm_MOV_UB_TO_L0C32_f32 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_UB_TO_L0C16_f16 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_UB_TO_L0C32_u32 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_UB_TO_L0C32_s32 : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;
  def int_hivm_MOV_UB_TO_L0C32_h2f : Intrinsic<[], [llvm_ptr_ty5, llvm_ptr_ty6, llvm_i64_ty, llvm_i64_ty],
    [IntrArgMemOnly, NoCapture<ArgIndex<0>>, WriteOnly<ArgIndex<0>>, NoCapture<ArgIndex<1>>, ReadOnly<ArgIndex<1>>]>;

  // SET FLAG
  def int_hivm_SET_FLAG_IMM : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrInaccessibleMemOnly]>;

  // WAIT FLAG
  def int_hivm_WAIT_FLAG_IMM : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrInaccessibleMemOnly]>;

  // MOVEMASK
  def int_hivm_MOVEMASK : Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrInaccessibleMemOnly]>;

  // BARRIER
  def int_hivm_BARRIER : Intrinsic<[], [llvm_i64_ty], [IntrInaccessibleMemOnly]>;

  def int_hivm_VTRANSPOSE_s16 : Intrinsic<[], [llvm_ptr_ty6, llvm_ptr_ty6], [IntrArgMemOnly]>;

  // GET BLOCK NUM
  def int_hivm_GET_BLOCK_NUM : Intrinsic<[llvm_i64_ty], [], [IntrNoMem]>;

  // GET BLOCK IDX
  def int_hivm_GET_BLOCK_IDX : Intrinsic<[llvm_i64_ty], [], [IntrNoMem]>;

  // GET CTRL
  def int_hivm_GET_CTRL : Intrinsic<[llvm_i64_ty], [],  [IntrInaccessibleMemOnly]>;

  // SET CTRL
  def int_hivm_SET_CTRL : Intrinsic<[], [llvm_i64_ty],  [IntrInaccessibleMemOnly]>;

  // SBITSET0
  def int_hivm_SBITSET0 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;

  // SBITSET1
  def int_hivm_SBITSET1 : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem]>;
}
