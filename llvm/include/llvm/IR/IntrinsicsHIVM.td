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
#ifdef LLVM_ENABLE_HIIPU
def llvm_ptr_ty1 : LLVMQualPointerType<llvm_ptr_ty, 1>; // __gm__
def llvm_ptr_ty2 : LLVMQualPointerType<llvm_ptr_ty, 2>; // __cbuf__
def llvm_ptr_ty3 : LLVMQualPointerType<llvm_ptr_ty, 3>; // __ca__
def llvm_ptr_ty4 : LLVMQualPointerType<llvm_ptr_ty, 4>; // __cb__
def llvm_ptr_ty5 : LLVMQualPointerType<llvm_ptr_ty, 5>; // __cc__
def llvm_ptr_ty6 : LLVMQualPointerType<llvm_ptr_ty, 6>; // __ubuf__
def llvm_ptr_ty7 : LLVMQualPointerType<llvm_ptr_ty, 7>; // __fbuf__

def llvm_ptr_i32_ty1   : LLVMQualPointerType<llvm_i32_ty, 1>;   // __gm__
def llvm_ptr_i32_ty6   : LLVMQualPointerType<llvm_i32_ty, 6>;   // __ubuf__
def llvm_ptr_i64_ty1   : LLVMQualPointerType<llvm_i64_ty, 1>;   // __gm__
def llvm_ptr_i64_ty6   : LLVMQualPointerType<llvm_i64_ty, 6>;   // __ubuf__
def llvm_ptr_half_ty1  : LLVMQualPointerType<llvm_half_ty, 1>;  // __gm__
def llvm_ptr_half_ty6  : LLVMQualPointerType<llvm_half_ty, 6>;  // __ubuf__
def llvm_ptr_float_ty1 : LLVMQualPointerType<llvm_float_ty, 1>; // __gm__
def llvm_ptr_float_ty6 : LLVMQualPointerType<llvm_float_ty, 6>; // __ubuf__

let TargetPrefix = "hivm" in {
  include "llvm/IR/cce_aicore_intrinsics_ir.include"

  // Common intrinsic
  def int_hivm_mulhi_i : ClangBuiltin<"__builtin_cce_mulhi_i">,
                        Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty],
                                  [IntrNoMem, Commutative]>;
  def int_hivm_mulhi_ui : ClangBuiltin<"__builtin_cce_mulhi_ui">,
                          Intrinsic<[llvm_i32_ty], [llvm_i32_ty, llvm_i32_ty],
                                    [IntrNoMem, Commutative]>;

  // VNOP/VSTNOP
  def int_hivm_vnop : ClangBuiltin<"__builtin_cce_vnop">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_vnopxn : ClangBuiltin<"__builtin_cce_vnopxn">,
      Intrinsic<[], [llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vstnop : ClangBuiltin<"__builtin_cce_vstnop">,
      Intrinsic<[], [llvm_i32_ty], [IntrHasSideEffects]>;

  def int_hivm_mem_bar_vv_all : ClangBuiltin<"__builtin_cce_mem_bar_vv_all">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vst_vld : ClangBuiltin<"__builtin_cce_mem_bar_vst_vld">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vld_vst : ClangBuiltin<"__builtin_cce_mem_bar_vld_vst">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vst_vst : ClangBuiltin<"__builtin_cce_mem_bar_vst_vst">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vs_all : ClangBuiltin<"__builtin_cce_mem_bar_vs_all">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vst_ld : ClangBuiltin<"__builtin_cce_mem_bar_vst_ld">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vld_st : ClangBuiltin<"__builtin_cce_mem_bar_vld_st">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_vst_st : ClangBuiltin<"__builtin_cce_mem_bar_vst_st">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_sv_all : ClangBuiltin<"__builtin_cce_mem_bar_sv_all">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_st_vld : ClangBuiltin<"__builtin_cce_mem_bar_st_vld">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_ld_vst : ClangBuiltin<"__builtin_cce_mem_bar_ld_vst">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_st_vst : ClangBuiltin<"__builtin_cce_mem_bar_st_vst">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_ss_all : ClangBuiltin<"__builtin_cce_mem_bar_ss_all">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_st_ld : ClangBuiltin<"__builtin_cce_mem_bar_st_ld">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_ld_st : ClangBuiltin<"__builtin_cce_mem_bar_ld_st">,
      Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_mem_bar_st_st : ClangBuiltin<"__builtin_cce_mem_bar_st_st">,
      Intrinsic<[], [], [IntrHasSideEffects]>;

  def int_hivm_dummy_def_s64: ClangBuiltin<"dummy_def_s64">, Intrinsic<[llvm_i64_ty], [], [IntrHasSideEffects]>;
  def int_hivm_dummy_def_s32: ClangBuiltin<"dummy_def_s32">, Intrinsic<[llvm_i32_ty], [], [IntrHasSideEffects]>;
  def int_hivm_dummy_use_s16: ClangBuiltin<"dummy_use_s16">, Intrinsic<[], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_dummy_use_padding_s16: ClangBuiltin<"dummy_use_padding_s16">, Intrinsic<[], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_dummy_use_s32: ClangBuiltin<"dummy_use_s32">, Intrinsic<[], [llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_dummy_use_vbool: ClangBuiltin<"dummy_use_vbool">, Intrinsic<[], [llvm_v256i1_ty], [IntrHasSideEffects]>;

  def int_hivm_vag_v210: ClangBuiltin<"__builtin_cce_vag_v210">,
    Intrinsic<[llvm_v1i32_ty], [llvm_i16_ty, llvm_i16_ty, llvm_i16_ty, llvm_i16_ty, llvm_i32_ty],
              [IntrHasSideEffects]>;

  def int_hivm_vag_v300: ClangBuiltin<"__builtin_cce_vag_v300">,
    Intrinsic<[llvm_v1i32_ty], [llvm_i16_ty, llvm_i16_ty, llvm_i16_ty, llvm_i16_ty],
              [IntrHasSideEffects]>;
  def int_hivm_vag_1_layer_v300: ClangBuiltin<"__builtin_cce_vag_1_layer_v300">,
    Intrinsic<[llvm_v1i32_ty], [llvm_i16_ty],
              [IntrHasSideEffects, IntrNoDuplicate]>;
  def int_hivm_vag_2_layer_v300: ClangBuiltin<"__builtin_cce_vag_2_layer_v300">,
    Intrinsic<[llvm_v1i32_ty], [llvm_i16_ty, llvm_i16_ty],
              [IntrHasSideEffects, IntrNoDuplicate]>;
  def int_hivm_vag_3_layer_v300: ClangBuiltin<"__builtin_cce_vag_3_layer_v300">,
    Intrinsic<[llvm_v1i32_ty], [llvm_i16_ty, llvm_i16_ty, llvm_i16_ty],
              [IntrHasSideEffects, IntrNoDuplicate]>;
  def int_hivm_vag_4_layer_v300: ClangBuiltin<"__builtin_cce_vag_4_layer_v300">,
    Intrinsic<[llvm_v1i32_ty], [llvm_i16_ty, llvm_i16_ty, llvm_i16_ty, llvm_i16_ty],
              [IntrHasSideEffects, IntrNoDuplicate]>;

  def int_hivm_vag_addr: ClangBuiltin<"vag_addr">, Intrinsic<[llvm_v1i32_ty], [llvm_i32_ty], [IntrNoMerge, IntrNoDuplicate]>;

  def int_hivm_vpd_b8:  ClangBuiltin<"vpd_b8">,  Intrinsic<[llvm_v256i1_ty], [], [IntrHasSideEffects]>;
  def int_hivm_vpd_b16: ClangBuiltin<"vpd_b16">, Intrinsic<[llvm_v256i1_ty], [], [IntrHasSideEffects]>;
  def int_hivm_vpd_b32: ClangBuiltin<"vpd_b32">, Intrinsic<[llvm_v256i1_ty], [], [IntrHasSideEffects]>;

  def int_hivm_movp_b16 : ClangBuiltin<"movp_b16">,
    Intrinsic<[llvm_v256i1_ty], [], [IntrHasSideEffects]>;
  def int_hivm_movp_b32 : ClangBuiltin<"movp_b32">,
    Intrinsic<[llvm_v256i1_ty], [], [IntrHasSideEffects]>;

  def int_hivm_plt_b8:  ClangBuiltin<"__builtin_cce_plt_b8">,  Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_plt_b16: ClangBuiltin<"__builtin_cce_plt_b16">, Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_plt_b32: ClangBuiltin<"__builtin_cce_plt_b32">, Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty], [IntrHasSideEffects]>;

  def int_hivm_pltm_b8:  ClangBuiltin<"pltm_b8">,  Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_pltm_b16: ClangBuiltin<"pltm_b16">, Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_pltm_b32: ClangBuiltin<"pltm_b32">, Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty], [IntrHasSideEffects]>;

  def int_hivm_plt_b8_v300:  ClangBuiltin<"__builtin_cce_plt_b8_v300">,Intrinsic<[llvm_v256i1_ty, llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_plt_b16_v300: ClangBuiltin<"__builtin_cce_plt_b16_v300">, Intrinsic<[llvm_v256i1_ty, llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_plt_b32_v300: ClangBuiltin<"__builtin_cce_plt_b32_v300">, Intrinsic<[llvm_v256i1_ty, llvm_i32_ty], [llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_pltm_b8_v300:  ClangBuiltin<"__builtin_cce_pltm_b8_v300">,  Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_pltm_b16_v300: ClangBuiltin<"__builtin_cce_pltm_b16_v300">, Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_pltm_b32_v300: ClangBuiltin<"__builtin_cce_pltm_b32_v300">, Intrinsic<[llvm_v256i1_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  def int_hivm_pge_b8:  ClangBuiltin<"pge_b8">,  Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_pge_b16: ClangBuiltin<"pge_b16">, Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_pge_b32: ClangBuiltin<"pge_b32">, Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_pge_b8_v210:  ClangBuiltin<"pge_b8_v210">,  Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_pge_b16_v210: ClangBuiltin<"pge_b16_v210">, Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_pge_b32_v210: ClangBuiltin<"pge_b32_v210">, Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  def int_hivm_pset_b8:  ClangBuiltin<"__builtin_cce_pset_b8">,  Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_pset_b16: ClangBuiltin<"__builtin_cce_pset_b16">, Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_pset_b32: ClangBuiltin<"__builtin_cce_pset_b32">, Intrinsic<[llvm_v256i1_ty], [llvm_i32_ty], [IntrNoMem]>;

  // PLD
  def int_hivm_pld_b8 : ClangBuiltin<"__builtin_cce_pld_b8">,
    Intrinsic<[llvm_v256i1_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // PLDI, Pre mode
  def int_hivm_pldi_b8 : ClangBuiltin<"__builtin_cce_pldi_b8">,
    Intrinsic<[llvm_v256i1_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // PLDI, Post mode
  def int_hivm_pldi_post_b8 : ClangBuiltin<"__builtin_cce_pldi_post_b8">, Intrinsic<[llvm_v256i1_ty, llvm_ptr_ty6],
              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  // PLDS, Pre mode
  def int_hivm_plds_b8 : ClangBuiltin<"__builtin_cce_plds_b8">,
    Intrinsic<[llvm_v256i1_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // PLDS, Post mode
  def int_hivm_plds_post_b8 : Intrinsic<[llvm_v256i1_ty, llvm_ptr_ty6],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // PST
  def int_hivm_pst_b8 : ClangBuiltin<"__builtin_cce_pst_b8">,
    Intrinsic<[], [llvm_v256i1_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // PSTI, Pre mode
  def int_hivm_psti_b8 : ClangBuiltin<"__builtin_cce_psti_b8">,
    Intrinsic<[], [llvm_v256i1_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  // PSTI, Post mode
  def int_hivm_psti_post_b8 : ClangBuiltin<"__builtin_cce_psti_post_b8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i1_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // PSTS, Pre mode
  def int_hivm_psts_b8 : ClangBuiltin<"__builtin_cce_psts_b8">,
    Intrinsic<[], [llvm_v256i1_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  // PSTS, Post mode
  def int_hivm_psts_post_b8 : ClangBuiltin<"__builtin_cce_psts_post_b8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i1_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  def int_hivm_get_vloopn_bound_b8:  ClangBuiltin<"get_vloopn_bound_b8">,  Intrinsic<[llvm_i16_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_get_vloopn_bound_b16: ClangBuiltin<"get_vloopn_bound_b16">, Intrinsic<[llvm_i16_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_get_vloopn_bound_b32: ClangBuiltin<"get_vloopn_bound_b32">, Intrinsic<[llvm_i16_ty], [llvm_i16_ty], [IntrHasSideEffects]>;
  def int_hivm_vloopn_b8:  Intrinsic<[], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vloopn_b16: Intrinsic<[], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vloopn_b32: Intrinsic<[], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  def int_hivm_fake_loop_bound: ClangBuiltin<"fake_loop_bound">, Intrinsic<[llvm_i16_ty], [llvm_i16_ty], [IntrHasSideEffects]>;

// VLOOPv2
  def int_hivm_vloopv2: Intrinsic<[], [llvm_i16_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vloopv2_v310: Intrinsic<[], [llvm_i16_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  // VL = 2048 bit
  // VEXT
  def int_hivm_vext: ClangBuiltin<"__builtin_cce_vext">,  Intrinsic<[], [llvm_v256i1_ty], [IntrHasSideEffects]>;

  // VL = 2048 bit
  // VEXTFA
  def int_hivm_vextfa: ClangBuiltin<"__builtin_cce_vextfa">,  Intrinsic<[], [llvm_v256i1_ty], [IntrHasSideEffects]>;


// VCP
  def int_hivm_vcp_v128s16: ClangBuiltin<"__builtin_cce_vcp_v128s16">, Intrinsic<[llvm_v128i16_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcp_v128u16: ClangBuiltin<"__builtin_cce_vcp_v128u16">, Intrinsic<[llvm_v128i16_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcp_v64s32: ClangBuiltin<"__builtin_cce_vcp_v64s32">, Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcp_v64u32: ClangBuiltin<"__builtin_cce_vcp_v64u32">, Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VADD
  def int_hivm_vadd_v64s32_m : ClangBuiltin<"__builtin_cce_vadd_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v64u32_m : ClangBuiltin<"__builtin_cce_vadd_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v128s16_m : ClangBuiltin<"__builtin_cce_vadd_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v128u16_m : ClangBuiltin<"__builtin_cce_vadd_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v256s8_m : ClangBuiltin<"__builtin_cce_vadd_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v256u8_m : ClangBuiltin<"__builtin_cce_vadd_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v64f32_m : ClangBuiltin<"__builtin_cce_vadd_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v128f16_m : ClangBuiltin<"__builtin_cce_vadd_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vadd_v64s32_x : ClangBuiltin<"__builtin_cce_vadd_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v64u32_x : ClangBuiltin<"__builtin_cce_vadd_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v128s16_x : ClangBuiltin<"__builtin_cce_vadd_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v128u16_x : ClangBuiltin<"__builtin_cce_vadd_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v256s8_x : ClangBuiltin<"__builtin_cce_vadd_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v256u8_x : ClangBuiltin<"__builtin_cce_vadd_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v64f32_x : ClangBuiltin<"__builtin_cce_vadd_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd_v128f16_x : ClangBuiltin<"__builtin_cce_vadd_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VADDC
  def int_hivm_vaddc_v64s32 : ClangBuiltin<"__builtin_cce_vaddc_v64s32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vaddc_v64u32 : ClangBuiltin<"__builtin_cce_vaddc_v64u32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VADDCS
  def int_hivm_vaddcs_v64s32 : ClangBuiltin<"__builtin_cce_vaddcs_v64s32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vaddcs_v64u32 : ClangBuiltin<"__builtin_cce_vaddcs_v64u32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSUB
  def int_hivm_vsub_v64s32_m : ClangBuiltin<"__builtin_cce_vsub_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v64u32_m : ClangBuiltin<"__builtin_cce_vsub_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v128s16_m : ClangBuiltin<"__builtin_cce_vsub_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v128u16_m : ClangBuiltin<"__builtin_cce_vsub_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v256s8_m : ClangBuiltin<"__builtin_cce_vsub_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v256u8_m : ClangBuiltin<"__builtin_cce_vsub_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v64f32_m : ClangBuiltin<"__builtin_cce_vsub_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v128f16_m : ClangBuiltin<"__builtin_cce_vsub_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vsub_v64s32_x : ClangBuiltin<"__builtin_cce_vsub_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v64u32_x : ClangBuiltin<"__builtin_cce_vsub_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v128s16_x : ClangBuiltin<"__builtin_cce_vsub_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v128u16_x : ClangBuiltin<"__builtin_cce_vsub_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v256s8_x : ClangBuiltin<"__builtin_cce_vsub_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v256u8_x : ClangBuiltin<"__builtin_cce_vsub_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v64f32_x : ClangBuiltin<"__builtin_cce_vsub_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsub_v128f16_x : ClangBuiltin<"__builtin_cce_vsub_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSUBC
  def int_hivm_vsubc_v64s32 : ClangBuiltin<"__builtin_cce_vsubc_v64s32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsubc_v64u32 : ClangBuiltin<"__builtin_cce_vsubc_v64u32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSUBCS
  def int_hivm_vsubcs_v64s32 : ClangBuiltin<"__builtin_cce_vsubcs_v64s32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsubcs_v64u32 : ClangBuiltin<"__builtin_cce_vsubcs_v64u32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMUL
  def int_hivm_vmul_v64s32_m : ClangBuiltin<"__builtin_cce_vmul_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v128s16_m : ClangBuiltin<"__builtin_cce_vmul_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v256s8_m : ClangBuiltin<"__builtin_cce_vmul_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v128u16_m : ClangBuiltin<"__builtin_cce_vmul_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v256u8_m : ClangBuiltin<"__builtin_cce_vmul_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v64f32_m : ClangBuiltin<"__builtin_cce_vmul_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v128f16_m : ClangBuiltin<"__builtin_cce_vmul_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmul_v64u32_x : ClangBuiltin<"__builtin_cce_vmul_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v64s32_x : ClangBuiltin<"__builtin_cce_vmul_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v128s16_x : ClangBuiltin<"__builtin_cce_vmul_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v256s8_x : ClangBuiltin<"__builtin_cce_vmul_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v128u16_x : ClangBuiltin<"__builtin_cce_vmul_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v256u8_x : ClangBuiltin<"__builtin_cce_vmul_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v64f32_x : ClangBuiltin<"__builtin_cce_vmul_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmul_v128f16_x : ClangBuiltin<"__builtin_cce_vmul_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMULL
  def int_hivm_vmull_v64s32 : ClangBuiltin<"__builtin_cce_vmull_v64s32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmull_v64u32 : ClangBuiltin<"__builtin_cce_vmull_v64u32">,
    Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMULA
  // VL = 2048 bit
  def int_hivm_vmula_v256s8_m : ClangBuiltin<"__builtin_cce_vmula_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v256u8_m : ClangBuiltin<"__builtin_cce_vmula_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v128s16_m : ClangBuiltin<"__builtin_cce_vmula_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v128u16_m : ClangBuiltin<"__builtin_cce_vmula_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v64u32_m : ClangBuiltin<"__builtin_cce_vmula_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v64s32_m : ClangBuiltin<"__builtin_cce_vmula_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v128f16_m : ClangBuiltin<"__builtin_cce_vmula_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmula_v64f32_m : ClangBuiltin<"__builtin_cce_vmula_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VABSDIF
  def int_hivm_vabsdif_v64s32_m : ClangBuiltin<"__builtin_cce_vabsdif_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v128s16_m : ClangBuiltin<"__builtin_cce_vabsdif_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v128u16_m : ClangBuiltin<"__builtin_cce_vabsdif_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v256s8_m : ClangBuiltin<"__builtin_cce_vabsdif_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v256u8_m : ClangBuiltin<"__builtin_cce_vabsdif_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v64f32_m : ClangBuiltin<"__builtin_cce_vabsdif_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v128f16_m : ClangBuiltin<"__builtin_cce_vabsdif_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vabsdif_v64s32_x : ClangBuiltin<"__builtin_cce_vabsdif_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v128s16_x : ClangBuiltin<"__builtin_cce_vabsdif_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v64u32_x : ClangBuiltin<"__builtin_cce_vabsdif_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v128u16_x : ClangBuiltin<"__builtin_cce_vabsdif_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v256s8_x : ClangBuiltin<"__builtin_cce_vabsdif_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v256u8_x : ClangBuiltin<"__builtin_cce_vabsdif_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v64f32_x : ClangBuiltin<"__builtin_cce_vabsdif_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabsdif_v128f16_x : ClangBuiltin<"__builtin_cce_vabsdif_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VADIF
  def int_hivm_vadif_v64s32_m : ClangBuiltin<"__builtin_cce_vadif_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadif_v64u32_m : ClangBuiltin<"__builtin_cce_vadif_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadif_v128s16_m : ClangBuiltin<"__builtin_cce_vadif_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadif_v128u16_m : ClangBuiltin<"__builtin_cce_vadif_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadif_v256s8_m : ClangBuiltin<"__builtin_cce_vadif_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadif_v256u8_m : ClangBuiltin<"__builtin_cce_vadif_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VADD3
  def int_hivm_vadd3_v64s32_m : ClangBuiltin<"__builtin_cce_vadd3_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd3_v64u32_m : ClangBuiltin<"__builtin_cce_vadd3_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd3_v128s16_m : ClangBuiltin<"__builtin_cce_vadd3_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd3_v128u16_m : ClangBuiltin<"__builtin_cce_vadd3_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd3_v256s8_m : ClangBuiltin<"__builtin_cce_vadd3_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadd3_v256u8_m : ClangBuiltin<"__builtin_cce_vadd3_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VSAD
  def int_hivm_vsad_v64s32_m : ClangBuiltin<"__builtin_cce_vsad_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsad_v64u32_m : ClangBuiltin<"__builtin_cce_vsad_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsad_v128s16_m : ClangBuiltin<"__builtin_cce_vsad_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsad_v128u16_m : ClangBuiltin<"__builtin_cce_vsad_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsad_v256s8_m : ClangBuiltin<"__builtin_cce_vsad_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsad_v256u8_m : ClangBuiltin<"__builtin_cce_vsad_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VSADD
  def int_hivm_vsadd_v128s16_m : ClangBuiltin<"__builtin_cce_vsadd_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsadd_v128s16_x : ClangBuiltin<"__builtin_cce_vsadd_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VSSUB
  def int_hivm_vssub_v128s16_m : ClangBuiltin<"__builtin_cce_vssub_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vssub_v128s16_x : ClangBuiltin<"__builtin_cce_vssub_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSADDS
  // VL = 2048 bit
  def int_hivm_vsadds_v128s16_m : ClangBuiltin<"__builtin_cce_vsadds_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsadds_v128s16_x : ClangBuiltin<"__builtin_cce_vsadds_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VMADD
  def int_hivm_vmadd_v64f32_m : ClangBuiltin<"__builtin_cce_vmadd_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmadd_v128f16_m : ClangBuiltin<"__builtin_cce_vmadd_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VRND
  def int_hivm_vrnd_v64s32_m : ClangBuiltin<"__builtin_cce_vrnd_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrnd_v128s16_m : ClangBuiltin<"__builtin_cce_vrnd_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vrnd_v64s32_x : ClangBuiltin<"__builtin_cce_vrnd_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrnd_v128s16_x : ClangBuiltin<"__builtin_cce_vrnd_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VPRELU
  def int_hivm_vprelu_v64f32_m : ClangBuiltin<"__builtin_cce_vprelu_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vprelu_v128f16_m : ClangBuiltin<"__builtin_cce_vprelu_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vprelu_v64f32_x : ClangBuiltin<"__builtin_cce_vprelu_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vprelu_v128f16_x : ClangBuiltin<"__builtin_cce_vprelu_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VDIVF
  def int_hivm_vdivf_v128u16_m : ClangBuiltin<"__builtin_cce_vdivf_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdivf_v128u16_x : ClangBuiltin<"__builtin_cce_vdivf_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VDIV
  def int_hivm_vdiv_v64s32_m : ClangBuiltin<"__builtin_cce_vdiv_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v64u32_m : ClangBuiltin<"__builtin_cce_vdiv_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v128s16_m : ClangBuiltin<"__builtin_cce_vdiv_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v128u16_m : ClangBuiltin<"__builtin_cce_vdiv_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v64f32_m : ClangBuiltin<"__builtin_cce_vdiv_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v128f16_m : ClangBuiltin<"__builtin_cce_vdiv_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vdiv_v64s32_x : ClangBuiltin<"__builtin_cce_vdiv_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v64u32_x : ClangBuiltin<"__builtin_cce_vdiv_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v128s16_x : ClangBuiltin<"__builtin_cce_vdiv_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v128u16_x : ClangBuiltin<"__builtin_cce_vdiv_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v64f32_x : ClangBuiltin<"__builtin_cce_vdiv_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vdiv_v128f16_x : ClangBuiltin<"__builtin_cce_vdiv_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // PRPNSET
  // VL = 2048 bit
  def int_hivm_prpnset_f16 : ClangBuiltin<"__builtin_cce_prpnset_f16">,
    Intrinsic<[], [llvm_i16_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;

  // PNOT
  // VL = 2048 bit
  def int_hivm_pnot_z : ClangBuiltin<"__builtin_cce_pnot_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // PAND
  // VL = 2048 bit
  def int_hivm_pand_z : ClangBuiltin<"__builtin_cce_pand_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // PMOV
  // VL = 2048 bit
  def int_hivm_pmov : ClangBuiltin<"__builtin_cce_pmov">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_pmov_z : ClangBuiltin<"__builtin_cce_pmov_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // POR
  // VL = 2048 bit
  def int_hivm_por_z : ClangBuiltin<"__builtin_cce_por_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // PSLIDE
  // VL = 2048 bit
  def int_hivm_pslide_b8 : ClangBuiltin<"__builtin_cce_pslide_b8">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_pslide_b16 : ClangBuiltin<"__builtin_cce_pslide_b16">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_pslide_b32 : ClangBuiltin<"__builtin_cce_pslide_b32">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_i16_ty], [IntrNoMem]>;

  // PINTLV
  def int_hivm_pintlv_b8 : Intrinsic<[llvm_v256i1_ty, llvm_v256i1_ty],
                                     [llvm_v256i1_ty, llvm_v256i1_ty],
                                     [IntrNoMem]>;
  def int_hivm_pintlv_b16 : Intrinsic<[llvm_v256i1_ty, llvm_v256i1_ty],
                                      [llvm_v256i1_ty, llvm_v256i1_ty],
                                      [IntrNoMem]>;
  def int_hivm_pintlv_b32 : Intrinsic<[llvm_v256i1_ty, llvm_v256i1_ty],
                                      [llvm_v256i1_ty, llvm_v256i1_ty],
                                      [IntrNoMem]>;

  // PDINTLV
  def int_hivm_pdintlv_b8 : Intrinsic<[llvm_v256i1_ty, llvm_v256i1_ty],
                                     [llvm_v256i1_ty, llvm_v256i1_ty],
                                     [IntrNoMem]>;
  def int_hivm_pdintlv_b16 : Intrinsic<[llvm_v256i1_ty, llvm_v256i1_ty],
                                      [llvm_v256i1_ty, llvm_v256i1_ty],
                                      [IntrNoMem]>;
  def int_hivm_pdintlv_b32 : Intrinsic<[llvm_v256i1_ty, llvm_v256i1_ty],
                                      [llvm_v256i1_ty, llvm_v256i1_ty],
                                      [IntrNoMem]>;
  // PXOR
  // VL = 2048 bit
  def int_hivm_pxor_z : ClangBuiltin<"__builtin_cce_pxor_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // PSEL
  // VL = 2048 bit
  def int_hivm_psel : ClangBuiltin<"__builtin_cce_psel">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_v256i1_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // PPACK
  // VL = 2048 bit
  def int_hivm_ppack_z : ClangBuiltin<"__builtin_cce_ppack_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // PUNPACK
  // VL = 2048 bit
  def int_hivm_punpack : ClangBuiltin<"__builtin_cce_punpack">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // WDUPS
  // VL = 2048 bit
  def int_hivm_wdups_v256u8 : ClangBuiltin<"__builtin_cce_wdups_v256u8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_wdups_v256s8 : ClangBuiltin<"__builtin_cce_wdups_v256s8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_wdups_v128u16 : ClangBuiltin<"__builtin_cce_wdups_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_wdups_v128s16 : ClangBuiltin<"__builtin_cce_wdups_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_i16_ty], [IntrNoMem]>;

  // WMOV
  // VL = 2048 bit
  def int_hivm_wmov_v256s24_m : ClangBuiltin<"__builtin_cce_wmov_v256s24_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmov_v128s48_m : ClangBuiltin<"__builtin_cce_wmov_v128s48_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i64_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmov_v256s24 : ClangBuiltin<"__builtin_cce_wmov_v256s24">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty], [IntrNoMem]>;
  def int_hivm_wmov_v128s48 : ClangBuiltin<"__builtin_cce_wmov_v128s48">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty], [IntrNoMem]>;

  // WADD
  // VL = 2048 bit
  def int_hivm_wadd_v256s8_m : ClangBuiltin<"__builtin_cce_wadd_v256s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadd_v128s16_m : ClangBuiltin<"__builtin_cce_wadd_v128s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadd_v256u8_m : ClangBuiltin<"__builtin_cce_wadd_v256u8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadd_v128u16_m : ClangBuiltin<"__builtin_cce_wadd_v128u16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wadd_v256s8_x : ClangBuiltin<"__builtin_cce_wadd_v256s8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadd_v128s16_x : ClangBuiltin<"__builtin_cce_wadd_v128s16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadd_v256u8_x : ClangBuiltin<"__builtin_cce_wadd_v256u8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadd_v128u16_x : ClangBuiltin<"__builtin_cce_wadd_v128u16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // WADDA
  def int_hivm_wadda_v256s8 : ClangBuiltin<"__builtin_cce_wadda_v256s8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadda_v128s16 : ClangBuiltin<"__builtin_cce_wadda_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadda_v256u8 : ClangBuiltin<"__builtin_cce_wadda_v256u8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wadda_v128u16 : ClangBuiltin<"__builtin_cce_wadda_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // WSUB
  def int_hivm_wsub_v256s8_m : ClangBuiltin<"__builtin_cce_wsub_v256s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsub_v128s16_m : ClangBuiltin<"__builtin_cce_wsub_v128s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsub_v256u8_m : ClangBuiltin<"__builtin_cce_wsub_v256u8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsub_v128u16_m : ClangBuiltin<"__builtin_cce_wsub_v128u16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wsub_v256s8_x : ClangBuiltin<"__builtin_cce_wsub_v256s8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsub_v128s16_x : ClangBuiltin<"__builtin_cce_wsub_v128s16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsub_v256u8_x : ClangBuiltin<"__builtin_cce_wsub_v256u8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsub_v128u16_x : ClangBuiltin<"__builtin_cce_wsub_v128u16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // WSUBA
  def int_hivm_wsuba_v256s8 : ClangBuiltin<"__builtin_cce_wsuba_v256s8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsuba_v128s16 : ClangBuiltin<"__builtin_cce_wsuba_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsuba_v256u8 : ClangBuiltin<"__builtin_cce_wsuba_v256u8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wsuba_v128u16 : ClangBuiltin<"__builtin_cce_wsuba_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // WMUL
  def int_hivm_wmul_v256u8u8_m : ClangBuiltin<"__builtin_cce_wmul_v256u8u8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v256u8s8_m : ClangBuiltin<"__builtin_cce_wmul_v256u8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v256s8s8_m : ClangBuiltin<"__builtin_cce_wmul_v256s8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16u16_m : ClangBuiltin<"__builtin_cce_wmul_v128u16u16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16s16_m : ClangBuiltin<"__builtin_cce_wmul_v128u16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128s16s16_m : ClangBuiltin<"__builtin_cce_wmul_v128s16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmul_v256u8u8_x : ClangBuiltin<"__builtin_cce_wmul_v256u8u8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v256u8s8_x : ClangBuiltin<"__builtin_cce_wmul_v256u8s8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v256s8s8_x : ClangBuiltin<"__builtin_cce_wmul_v256s8s8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16u16_x : ClangBuiltin<"__builtin_cce_wmul_v128u16u16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16s16_x : ClangBuiltin<"__builtin_cce_wmul_v128u16s16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128s16s16_x : ClangBuiltin<"__builtin_cce_wmul_v128s16s16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmul_v256u8s16_x : ClangBuiltin<"__builtin_cce_wmul_v256u8s16_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v256s8s16_x : ClangBuiltin<"__builtin_cce_wmul_v256s8s16_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16u32_x : ClangBuiltin<"__builtin_cce_wmul_v128u16u32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16s32_x : ClangBuiltin<"__builtin_cce_wmul_v128u16s32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128s16u32_x : ClangBuiltin<"__builtin_cce_wmul_v128s16u32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128s16s32_x : ClangBuiltin<"__builtin_cce_wmul_v128s16s32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmul_v128u16u32_v300 : ClangBuiltin<"__builtin_cce_wmul_v128u16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128u16s32_v300 : ClangBuiltin<"__builtin_cce_wmul_v128u16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128s16u32_v300 : ClangBuiltin<"__builtin_cce_wmul_v128s16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmul_v128s16s32_v300 : ClangBuiltin<"__builtin_cce_wmul_v128s16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmul_v256u8s16_v300 : ClangBuiltin<"__builtin_cce_wmul_v256u8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;
  def int_hivm_wmul_v256s8s16_v300 : ClangBuiltin<"__builtin_cce_wmul_v256s8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;

  // WMULA
  def int_hivm_wmula_v256u8u8_m : ClangBuiltin<"__builtin_cce_wmula_v256u8u8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmula_v256u8s8_m : ClangBuiltin<"__builtin_cce_wmula_v256u8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmula_v256s8s8_m : ClangBuiltin<"__builtin_cce_wmula_v256s8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128u16u16_m : ClangBuiltin<"__builtin_cce_wmula_v128u16u16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128u16s16_m : ClangBuiltin<"__builtin_cce_wmula_v128u16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128s16s16_m : ClangBuiltin<"__builtin_cce_wmula_v128s16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmula_v256u8s16_m : ClangBuiltin<"__builtin_cce_wmula_v256u8s16_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v256s8s16_m : ClangBuiltin<"__builtin_cce_wmula_v256s8s16_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128u16u32_m : ClangBuiltin<"__builtin_cce_wmula_v128u16u32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128u16s32_m : ClangBuiltin<"__builtin_cce_wmula_v128u16s32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128s16u32_m : ClangBuiltin<"__builtin_cce_wmula_v128s16u32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128s16s32_m : ClangBuiltin<"__builtin_cce_wmula_v128s16s32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmula_v128u16u32_v300 : ClangBuiltin<"__builtin_cce_wmula_v128u16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128u16s32_v300 : ClangBuiltin<"__builtin_cce_wmula_v128u16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128s16u32_v300 : ClangBuiltin<"__builtin_cce_wmula_v128s16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmula_v128s16s32_v300 : ClangBuiltin<"__builtin_cce_wmula_v128s16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmula_v256u8s16_v300 : ClangBuiltin<"__builtin_cce_wmula_v256u8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;
  def int_hivm_wmula_v256s8s16_v300 : ClangBuiltin<"__builtin_cce_wmula_v256s8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;

  // WMULS
  def int_hivm_wmuls_v256u8u8_m : ClangBuiltin<"__builtin_cce_wmuls_v256u8u8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v256u8s8_m : ClangBuiltin<"__builtin_cce_wmuls_v256u8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v256s8s8_m : ClangBuiltin<"__builtin_cce_wmuls_v256s8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16u16_m : ClangBuiltin<"__builtin_cce_wmuls_v128u16u16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16s16_m : ClangBuiltin<"__builtin_cce_wmuls_v128u16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128s16s16_m : ClangBuiltin<"__builtin_cce_wmuls_v128s16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmuls_v256u8u8_x : ClangBuiltin<"__builtin_cce_wmuls_v256u8u8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v256u8s8_x : ClangBuiltin<"__builtin_cce_wmuls_v256u8s8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v256s8s8_x : ClangBuiltin<"__builtin_cce_wmuls_v256s8s8_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16u16_x : ClangBuiltin<"__builtin_cce_wmuls_v128u16u16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16s16_x : ClangBuiltin<"__builtin_cce_wmuls_v128u16s16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128s16s16_x : ClangBuiltin<"__builtin_cce_wmuls_v128s16s16_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmuls_v256u8s16_x : ClangBuiltin<"__builtin_cce_wmuls_v256u8s16_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v256s8s16_x : ClangBuiltin<"__builtin_cce_wmuls_v256s8s16_x">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16u32_x : ClangBuiltin<"__builtin_cce_wmuls_v128u16u32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16s32_x : ClangBuiltin<"__builtin_cce_wmuls_v128u16s32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128s16u32_x : ClangBuiltin<"__builtin_cce_wmuls_v128s16u32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128s16s32_x : ClangBuiltin<"__builtin_cce_wmuls_v128s16s32_x">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmuls_v128u16u32_v300 : ClangBuiltin<"__builtin_cce_wmuls_v128u16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128u16s32_v300 : ClangBuiltin<"__builtin_cce_wmuls_v128u16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128s16u32_v300 : ClangBuiltin<"__builtin_cce_wmuls_v128s16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v128s16s32_v300 : ClangBuiltin<"__builtin_cce_wmuls_v128s16s32_v300">,
     Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmuls_v256u8s16_v300 : ClangBuiltin<"__builtin_cce_wmuls_v256u8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_wmuls_v256s8s16_v300 : ClangBuiltin<"__builtin_cce_wmuls_v256s8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i8_ty, llvm_i16_ty], [IntrNoMem]>;

  // WMULAS
  def int_hivm_wmulas_v256u8u8_m : ClangBuiltin<"__builtin_cce_wmulas_v256u8u8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v256u8s8_m : ClangBuiltin<"__builtin_cce_wmulas_v256u8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v256s8s8_m : ClangBuiltin<"__builtin_cce_wmulas_v256s8s8_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128u16u16_m : ClangBuiltin<"__builtin_cce_wmulas_v128u16u16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128u16s16_m : ClangBuiltin<"__builtin_cce_wmulas_v128u16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128s16s16_m : ClangBuiltin<"__builtin_cce_wmulas_v128s16s16_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wmulas_v256u8s16_m : ClangBuiltin<"__builtin_cce_wmulas_v256u8s16_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v256s8s16_m : ClangBuiltin<"__builtin_cce_wmulas_v256s8s16_m">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128u16u32_m : ClangBuiltin<"__builtin_cce_wmulas_v128u16u32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128u16s32_m : ClangBuiltin<"__builtin_cce_wmulas_v128u16s32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128s16u32_m : ClangBuiltin<"__builtin_cce_wmulas_v128s16u32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128s16s32_m : ClangBuiltin<"__builtin_cce_wmulas_v128s16s32_m">,
    Intrinsic<[llvm_v64i128_ty], [llvm_v64i128_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmulas_v128u16u32_v300 : ClangBuiltin<"__builtin_cce_wmulas_v128u16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128u16s32_v300 : ClangBuiltin<"__builtin_cce_wmulas_v128u16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128s16u32_v300 : ClangBuiltin<"__builtin_cce_wmulas_v128s16u32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v128s16s32_v300 : ClangBuiltin<"__builtin_cce_wmulas_v128s16s32_v300">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_wmulas_v256u8s16_v300 : ClangBuiltin<"__builtin_cce_wmulas_v256u8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_wmulas_v256s8s16_v300 : ClangBuiltin<"__builtin_cce_wmulas_v256s8s16_v300">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i16_ty], [IntrNoMem]>;

  // WADDSUB
  def int_hivm_waddsub_v256s8 : ClangBuiltin<"__builtin_cce_waddsub_v256s8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_waddsub_v128s16 : ClangBuiltin<"__builtin_cce_waddsub_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_waddsub_v256u8 : ClangBuiltin<"__builtin_cce_waddsub_v256u8">,
    Intrinsic<[llvm_v256i32_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_waddsub_v128u16 : ClangBuiltin<"__builtin_cce_waddsub_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // WPACK rs=0
  def int_hivm_wpack_rs0_v256s242s8_m : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v256s242u8_m : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482s16_m : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482u16_m : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v64s642s32_m : ClangBuiltin<"__builtin_cce_wpack_rs0_v64s642s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i128_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpack_rs0_v256s242s8_x : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v256s242u8_x : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482s16_x : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482u16_x : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v64s642s32_x : ClangBuiltin<"__builtin_cce_wpack_rs0_v64s642s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpack_rs0_v256s242s8_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242s8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v256s242u8_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242u8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482s16_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482u16_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v64s642s32_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v64s642s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v256s242s16_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v256s242u16_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v256s242u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs0_v128s482s32_u : ClangBuiltin<"__builtin_cce_wpack_rs0_v128s482s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i64_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // WPACK rs=1
  def int_hivm_wpack_rs1_v256s242s8_m : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v256s242u8_m : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482s16_m : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482u16_m : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v64s642s32_m : ClangBuiltin<"__builtin_cce_wpack_rs1_v64s642s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i128_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpack_rs1_v256s242s8_x : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v256s242u8_x : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482s16_x : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482u16_x : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v64s642s32_x : ClangBuiltin<"__builtin_cce_wpack_rs1_v64s642s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpack_rs1_v256s242s8_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242s8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v256s242u8_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242u8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482s16_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482u16_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v64s642s32_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v64s642s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v256s242s16_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v256s242u16_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v256s242u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpack_rs1_v128s482s32_u : ClangBuiltin<"__builtin_cce_wpack_rs1_v128s482s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i64_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // WPACKS #rs=0
  def int_hivm_wpacks_rs0_v256s242s8_m : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v256s242u8_m : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482s16_m : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482u16_m : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v64s642s32_m : ClangBuiltin<"__builtin_cce_wpacks_rs0_v64s642s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i128_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpacks_rs0_v256s242s8_x : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v256s242u8_x : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482s16_x : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482u16_x : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v64s642s32_x : ClangBuiltin<"__builtin_cce_wpacks_rs0_v64s642s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpacks_rs0_v256s242s8_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242s8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v256s242u8_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242u8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482s16_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482u16_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v64s642s32_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v64s642s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v256s242s16_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v256s242u16_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v256s242u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs0_v128s482s32_u : ClangBuiltin<"__builtin_cce_wpacks_rs0_v128s482s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // WPACKS #rs=1
  def int_hivm_wpacks_rs1_v256s242s8_m : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v256s242u8_m : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482s16_m : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482u16_m : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v64s642s32_m : ClangBuiltin<"__builtin_cce_wpacks_rs1_v64s642s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i128_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpacks_rs1_v256s242s8_x : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v256s242u8_x : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482s16_x : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482u16_x : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v64s642s32_x : ClangBuiltin<"__builtin_cce_wpacks_rs1_v64s642s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_wpacks_rs1_v256s242s8_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242s8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v256s242u8_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242u8_u">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482s16_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482u16_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v64s642s32_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v64s642s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i128_ty, llvm_i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v256s242s16_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242s16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v256s242u16_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v256s242u16_u">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i32_ty, llvm_i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wpacks_rs1_v128s482s32_u : ClangBuiltin<"__builtin_cce_wpacks_rs1_v128s482s32_u">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i64_ty, llvm_i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // WCVT48
  def int_hivm_wcvt48_v128s48_m : ClangBuiltin<"__builtin_cce_wcvt48_v128s48_m">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v64i32_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wcvt48_v128s48_x : ClangBuiltin<"__builtin_cce_wcvt48_v128s48_x">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v64i32_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;

  // WFIFR2
  def int_hivm_wfifr2_v256s8 : ClangBuiltin<"__builtin_cce_wfifr2_v256s8">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2_v256u8 : ClangBuiltin<"__builtin_cce_wfifr2_v256u8">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2_v128s16 : ClangBuiltin<"__builtin_cce_wfifr2_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2_v128u16 : ClangBuiltin<"__builtin_cce_wfifr2_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;

  // WFIFR2A
  def int_hivm_wfifr2a_v256s8 : ClangBuiltin<"__builtin_cce_wfifr2a_v256s8">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2a_v256u8 : ClangBuiltin<"__builtin_cce_wfifr2a_v256u8">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2a_v128s16 : ClangBuiltin<"__builtin_cce_wfifr2a_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2a_v128u16 : ClangBuiltin<"__builtin_cce_wfifr2a_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;

  // WFIFR2S
  def int_hivm_wfifr2s_v256s8 : ClangBuiltin<"__builtin_cce_wfifr2s_v256s8">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2s_v256u8 : ClangBuiltin<"__builtin_cce_wfifr2s_v256u8">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2s_v128s16 : ClangBuiltin<"__builtin_cce_wfifr2s_v128s16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_wfifr2s_v128u16 : ClangBuiltin<"__builtin_cce_wfifr2s_v128u16">,
    Intrinsic<[llvm_v128i64_ty], [llvm_v128i64_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;

  // VINTLV
  // only consider VL = 2048 bit for now
  def int_hivm_vintlv_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                         [llvm_v64i32_ty, llvm_v64i32_ty],
                                         [IntrNoMem]>;
  def int_hivm_vintlv_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                         [llvm_v64i32_ty, llvm_v64i32_ty],
                                         [IntrNoMem]>;
  def int_hivm_vintlv_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                          [llvm_v128i16_ty, llvm_v128i16_ty],
                                          [IntrNoMem]>;
  def int_hivm_vintlv_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                          [llvm_v128i16_ty, llvm_v128i16_ty],
                                          [IntrNoMem]>;
  def int_hivm_vintlv_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                         [llvm_v256i8_ty, llvm_v256i8_ty],
                                         [IntrNoMem]>;
  def int_hivm_vintlv_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                         [llvm_v256i8_ty, llvm_v256i8_ty],
                                         [IntrNoMem]>;
  def int_hivm_vintlv_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty],
                                         [llvm_v64f32_ty, llvm_v64f32_ty],
                                         [IntrNoMem]>;
  def int_hivm_vintlv_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty],
                                          [llvm_v128f16_ty, llvm_v128f16_ty],
                                          [IntrNoMem]>;

  // VDINTLV
  def int_hivm_vdintlv_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                          [llvm_v32i64_ty, llvm_v32i64_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                          [llvm_v32i64_ty, llvm_v32i64_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                          [llvm_v64i32_ty, llvm_v64i32_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                          [llvm_v64i32_ty, llvm_v64i32_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                           [llvm_v128i16_ty, llvm_v128i16_ty],
                                           [IntrNoMem]>;
  def int_hivm_vdintlv_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                           [llvm_v128i16_ty, llvm_v128i16_ty],
                                           [IntrNoMem]>;
  def int_hivm_vdintlv_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                          [llvm_v256i8_ty, llvm_v256i8_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                          [llvm_v256i8_ty, llvm_v256i8_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty],
                                          [llvm_v64f32_ty, llvm_v64f32_ty],
                                          [IntrNoMem]>;
  def int_hivm_vdintlv_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty],
                                           [llvm_v128f16_ty, llvm_v128f16_ty],
                                           [IntrNoMem]>;

  // VSLIDE
  def int_hivm_vslide_v64s32 : ClangBuiltin<"__builtin_cce_vslide_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v64u32 : ClangBuiltin<"__builtin_cce_vslide_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v128s16 : ClangBuiltin<"__builtin_cce_vslide_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v128u16 : ClangBuiltin<"__builtin_cce_vslide_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v256s8 : ClangBuiltin<"__builtin_cce_vslide_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v256u8 : ClangBuiltin<"__builtin_cce_vslide_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v64f32 : ClangBuiltin<"__builtin_cce_vslide_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_i16_ty], [IntrNoMem]>;
  def int_hivm_vslide_v128f16 : ClangBuiltin<"__builtin_cce_vslide_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_i16_ty], [IntrNoMem]>;

  // VINTEGRALS1-VINTEGRALS3
  def int_hivm_vintegrals1 : ClangBuiltin<"__builtin_cce_vintegrals1">,
    Intrinsic<[], [llvm_v256i8_ty], [IntrHasSideEffects]>;
  def int_hivm_vintegrals2 : ClangBuiltin<"__builtin_cce_vintegrals2">,
    Intrinsic<[], [], [IntrHasSideEffects]>;
  def int_hivm_vintegrals3 : ClangBuiltin<"__builtin_cce_vintegrals3">,
    Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;

  // VINTEGRALV2
  def int_hivm_vintegralv2 : ClangBuiltin<"__builtin_cce_vintegralv2">,
    Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty], [llvm_v128i16_ty], [IntrNoMem]>;

  // CHIST0-CHIST3
  def int_hivm_chist0_v256u32_m : ClangBuiltin<"__builtin_cce_chist0_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_chist1_v256u32_m : ClangBuiltin<"__builtin_cce_chist1_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_chist2_v256u32_m : ClangBuiltin<"__builtin_cce_chist2_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_chist3_v256u32_m : ClangBuiltin<"__builtin_cce_chist3_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_chist0_v128u16_m : ClangBuiltin<"__builtin_cce_chist0_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_chist1_v128u16_m : ClangBuiltin<"__builtin_cce_chist1_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_chist2_v128u16_m : ClangBuiltin<"__builtin_cce_chist2_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_chist3_v128u16_m : ClangBuiltin<"__builtin_cce_chist3_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // DHIST0-DHIST3
  def int_hivm_dhist0_v256u32_m : ClangBuiltin<"__builtin_cce_dhist0_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_dhist1_v256u32_m : ClangBuiltin<"__builtin_cce_dhist1_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_dhist2_v256u32_m : ClangBuiltin<"__builtin_cce_dhist2_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_dhist3_v256u32_m : ClangBuiltin<"__builtin_cce_dhist3_v256u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_dhist0_v128u16_m : ClangBuiltin<"__builtin_cce_dhist0_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_dhist1_v128u16_m : ClangBuiltin<"__builtin_cce_dhist1_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_dhist2_v128u16_m : ClangBuiltin<"__builtin_cce_dhist2_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_dhist3_v128u16_m : ClangBuiltin<"__builtin_cce_dhist3_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // DHISTV2
  def int_hivm_dhistv2_m : ClangBuiltin<"__builtin_cce_dhistv2_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // CHISTV2
  def int_hivm_chistv2_m : ClangBuiltin<"__builtin_cce_chistv2_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // VAXPY
  // VL = 2048 bit
  def int_hivm_vaxpy_v128f16_m : ClangBuiltin<"__builtin_cce_vaxpy_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vaxpy_v64f32_m : ClangBuiltin<"__builtin_cce_vaxpy_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VAND
  def int_hivm_vand_v64s32_m : ClangBuiltin<"__builtin_cce_vand_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v64u32_m : ClangBuiltin<"__builtin_cce_vand_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v128s16_m : ClangBuiltin<"__builtin_cce_vand_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v128u16_m : ClangBuiltin<"__builtin_cce_vand_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v256s8_m : ClangBuiltin<"__builtin_cce_vand_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v256u8_m : ClangBuiltin<"__builtin_cce_vand_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v64f32_m : ClangBuiltin<"__builtin_cce_vand_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v128f16_m : ClangBuiltin<"__builtin_cce_vand_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vand_v64s32_x : ClangBuiltin<"__builtin_cce_vand_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v64u32_x : ClangBuiltin<"__builtin_cce_vand_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v128s16_x : ClangBuiltin<"__builtin_cce_vand_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v128u16_x : ClangBuiltin<"__builtin_cce_vand_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v256s8_x : ClangBuiltin<"__builtin_cce_vand_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v256u8_x : ClangBuiltin<"__builtin_cce_vand_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v64f32_x : ClangBuiltin<"__builtin_cce_vand_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vand_v128f16_x : ClangBuiltin<"__builtin_cce_vand_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VOR
  def int_hivm_vor_v64s32_m : ClangBuiltin<"__builtin_cce_vor_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v64u32_m : ClangBuiltin<"__builtin_cce_vor_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v128s16_m : ClangBuiltin<"__builtin_cce_vor_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v128u16_m : ClangBuiltin<"__builtin_cce_vor_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v256s8_m : ClangBuiltin<"__builtin_cce_vor_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v256u8_m : ClangBuiltin<"__builtin_cce_vor_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v64f32_m : ClangBuiltin<"__builtin_cce_vor_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v128f16_m : ClangBuiltin<"__builtin_cce_vor_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vor_v64s32_x : ClangBuiltin<"__builtin_cce_vor_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v64u32_x : ClangBuiltin<"__builtin_cce_vor_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v128s16_x : ClangBuiltin<"__builtin_cce_vor_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v128u16_x : ClangBuiltin<"__builtin_cce_vor_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v256s8_x : ClangBuiltin<"__builtin_cce_vor_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v256u8_x : ClangBuiltin<"__builtin_cce_vor_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v64f32_x : ClangBuiltin<"__builtin_cce_vor_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vor_v128f16_x : ClangBuiltin<"__builtin_cce_vor_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VXOR
  def int_hivm_vxor_v64s32_m : ClangBuiltin<"__builtin_cce_vxor_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v64u32_m : ClangBuiltin<"__builtin_cce_vxor_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v128s16_m : ClangBuiltin<"__builtin_cce_vxor_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v128u16_m : ClangBuiltin<"__builtin_cce_vxor_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v256s8_m : ClangBuiltin<"__builtin_cce_vxor_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v256u8_m : ClangBuiltin<"__builtin_cce_vxor_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v64f32_m : ClangBuiltin<"__builtin_cce_vxor_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v128f16_m : ClangBuiltin<"__builtin_cce_vxor_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vxor_v64s32_x : ClangBuiltin<"__builtin_cce_vxor_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v64u32_x : ClangBuiltin<"__builtin_cce_vxor_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v128s16_x : ClangBuiltin<"__builtin_cce_vxor_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v128u16_x : ClangBuiltin<"__builtin_cce_vxor_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v256s8_x : ClangBuiltin<"__builtin_cce_vxor_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v256u8_x : ClangBuiltin<"__builtin_cce_vxor_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v64f32_x : ClangBuiltin<"__builtin_cce_vxor_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vxor_v128f16_x : ClangBuiltin<"__builtin_cce_vxor_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMAX
  // VL = 2048 bit
  def int_hivm_vmax_v256s8_m : ClangBuiltin<"__builtin_cce_vmax_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v128s16_m : ClangBuiltin<"__builtin_cce_vmax_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v64s32_m : ClangBuiltin<"__builtin_cce_vmax_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v256u8_m : ClangBuiltin<"__builtin_cce_vmax_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v128u16_m : ClangBuiltin<"__builtin_cce_vmax_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v64u32_m : ClangBuiltin<"__builtin_cce_vmax_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v128f16_m : ClangBuiltin<"__builtin_cce_vmax_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v64f32_m : ClangBuiltin<"__builtin_cce_vmax_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmax_v256s8_x : ClangBuiltin<"__builtin_cce_vmax_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v128s16_x : ClangBuiltin<"__builtin_cce_vmax_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v64s32_x : ClangBuiltin<"__builtin_cce_vmax_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v256u8_x : ClangBuiltin<"__builtin_cce_vmax_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v128u16_x : ClangBuiltin<"__builtin_cce_vmax_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v64u32_x : ClangBuiltin<"__builtin_cce_vmax_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v128f16_x : ClangBuiltin<"__builtin_cce_vmax_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmax_v64f32_x : ClangBuiltin<"__builtin_cce_vmax_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMIN
  // VL = 2048 bit
  def int_hivm_vmin_v256s8_m : ClangBuiltin<"__builtin_cce_vmin_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v128s16_m : ClangBuiltin<"__builtin_cce_vmin_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v64s32_m : ClangBuiltin<"__builtin_cce_vmin_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v256u8_m : ClangBuiltin<"__builtin_cce_vmin_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v128u16_m : ClangBuiltin<"__builtin_cce_vmin_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v64u32_m : ClangBuiltin<"__builtin_cce_vmin_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v128f16_m : ClangBuiltin<"__builtin_cce_vmin_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v64f32_m : ClangBuiltin<"__builtin_cce_vmin_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmin_v256s8_x : ClangBuiltin<"__builtin_cce_vmin_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v128s16_x : ClangBuiltin<"__builtin_cce_vmin_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v64s32_x : ClangBuiltin<"__builtin_cce_vmin_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v256u8_x : ClangBuiltin<"__builtin_cce_vmin_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v128u16_x : ClangBuiltin<"__builtin_cce_vmin_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v64u32_x : ClangBuiltin<"__builtin_cce_vmin_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v128f16_x : ClangBuiltin<"__builtin_cce_vmin_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmin_v64f32_x : ClangBuiltin<"__builtin_cce_vmin_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSHL
  // VL = 2048 bit
  def int_hivm_vshl_v128s16_m : ClangBuiltin<"__builtin_cce_vshl_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v64s32_m : ClangBuiltin<"__builtin_cce_vshl_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v256u8_m : ClangBuiltin<"__builtin_cce_vshl_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v128u16_m : ClangBuiltin<"__builtin_cce_vshl_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v64u32_m : ClangBuiltin<"__builtin_cce_vshl_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vshl_v128s16_x : ClangBuiltin<"__builtin_cce_vshl_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v64s32_x : ClangBuiltin<"__builtin_cce_vshl_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v256s8_x : ClangBuiltin<"__builtin_cce_vshl_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v256u8_x : ClangBuiltin<"__builtin_cce_vshl_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v128u16_x : ClangBuiltin<"__builtin_cce_vshl_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshl_v64u32_x : ClangBuiltin<"__builtin_cce_vshl_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSHR
  // VL = 2048 bit
  def int_hivm_vshr_v128s16_m : ClangBuiltin<"__builtin_cce_vshr_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v64s32_m : ClangBuiltin<"__builtin_cce_vshr_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v256u8_m : ClangBuiltin<"__builtin_cce_vshr_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v128u16_m : ClangBuiltin<"__builtin_cce_vshr_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v64u32_m : ClangBuiltin<"__builtin_cce_vshr_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vshr_v128s16_x : ClangBuiltin<"__builtin_cce_vshr_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v64s32_x : ClangBuiltin<"__builtin_cce_vshr_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v256s8_x : ClangBuiltin<"__builtin_cce_vshr_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v256u8_x : ClangBuiltin<"__builtin_cce_vshr_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v128u16_x : ClangBuiltin<"__builtin_cce_vshr_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshr_v64u32_x : ClangBuiltin<"__builtin_cce_vshr_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VRSQRT
  // VL = 2048 bit
  def int_hivm_vrsqrt_v128f16_m : ClangBuiltin<"__builtin_cce_vrsqrt_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrsqrt_v64f32_m : ClangBuiltin<"__builtin_cce_vrsqrt_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vrsqrt_v128f16_x : ClangBuiltin<"__builtin_cce_vrsqrt_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrsqrt_v64f32_x : ClangBuiltin<"__builtin_cce_vrsqrt_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSQRT
  // VL = 2048 bit
  def int_hivm_vsqrt_v128f16_m : ClangBuiltin<"__builtin_cce_vsqrt_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsqrt_v64f32_m : ClangBuiltin<"__builtin_cce_vsqrt_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vsqrt_v128f16_x : ClangBuiltin<"__builtin_cce_vsqrt_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsqrt_v64f32_x : ClangBuiltin<"__builtin_cce_vsqrt_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VEXP
  // VL = 2048 bit
  def int_hivm_vexp_v128f16_m : ClangBuiltin<"__builtin_cce_vexp_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vexp_v64f32_m : ClangBuiltin<"__builtin_cce_vexp_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vexp_v128f16_x : ClangBuiltin<"__builtin_cce_vexp_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vexp_v64f32_x : ClangBuiltin<"__builtin_cce_vexp_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VREC
  // VL = 2048 bit
  def int_hivm_vrec_v128f16_m : ClangBuiltin<"__builtin_cce_vrec_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrec_v64f32_m : ClangBuiltin<"__builtin_cce_vrec_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vrec_v128f16_x : ClangBuiltin<"__builtin_cce_vrec_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrec_v64f32_x : ClangBuiltin<"__builtin_cce_vrec_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VLN
  // VL = 2048 bit
  def int_hivm_vln_v128f16_m : ClangBuiltin<"__builtin_cce_vln_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vln_v64f32_m : ClangBuiltin<"__builtin_cce_vln_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vln_v128f16_x : ClangBuiltin<"__builtin_cce_vln_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vln_v64f32_x : ClangBuiltin<"__builtin_cce_vln_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VRELU
  // VL = 2048 bit
  def int_hivm_vrelu_v128f16_m : ClangBuiltin<"__builtin_cce_vrelu_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrelu_v64f32_m : ClangBuiltin<"__builtin_cce_vrelu_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrelu_v64s32_m : ClangBuiltin<"__builtin_cce_vrelu_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vrelu_v128f16_x : ClangBuiltin<"__builtin_cce_vrelu_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrelu_v64f32_x : ClangBuiltin<"__builtin_cce_vrelu_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrelu_v64s32_x : ClangBuiltin<"__builtin_cce_vrelu_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VNOT
  // VL = 2048 bit
  def int_hivm_vnot_v64s32_m : ClangBuiltin<"__builtin_cce_vnot_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v64u32_m : ClangBuiltin<"__builtin_cce_vnot_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v128s16_m : ClangBuiltin<"__builtin_cce_vnot_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v128u16_m : ClangBuiltin<"__builtin_cce_vnot_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v256s8_m : ClangBuiltin<"__builtin_cce_vnot_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v256u8_m : ClangBuiltin<"__builtin_cce_vnot_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v64f32_m : ClangBuiltin<"__builtin_cce_vnot_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v128f16_m : ClangBuiltin<"__builtin_cce_vnot_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vnot_v64s32_x : ClangBuiltin<"__builtin_cce_vnot_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v64u32_x : ClangBuiltin<"__builtin_cce_vnot_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v128s16_x : ClangBuiltin<"__builtin_cce_vnot_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v128u16_x : ClangBuiltin<"__builtin_cce_vnot_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v256s8_x : ClangBuiltin<"__builtin_cce_vnot_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v256u8_x : ClangBuiltin<"__builtin_cce_vnot_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v64f32_x : ClangBuiltin<"__builtin_cce_vnot_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vnot_v128f16_x : ClangBuiltin<"__builtin_cce_vnot_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSEL
  // VL = 2048 bit
  def int_hivm_vsel_v256u8 : ClangBuiltin<"__builtin_cce_vsel_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsel_v256s8 : ClangBuiltin<"__builtin_cce_vsel_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vsel_v128u16 : ClangBuiltin<"__builtin_cce_vsel_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsel_v128s16 : ClangBuiltin<"__builtin_cce_vsel_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsel_v128f16 : ClangBuiltin<"__builtin_cce_vsel_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vsel_v64u32 : ClangBuiltin<"__builtin_cce_vsel_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsel_v64s32 : ClangBuiltin<"__builtin_cce_vsel_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsel_v64f32 : ClangBuiltin<"__builtin_cce_vsel_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMOV
  // VL = 2048 bit
  def int_hivm_vmov_v256u8_m : ClangBuiltin<"__builtin_cce_vmov_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v256s8_m : ClangBuiltin<"__builtin_cce_vmov_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128u16_m : ClangBuiltin<"__builtin_cce_vmov_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128s16_m : ClangBuiltin<"__builtin_cce_vmov_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128f16_m : ClangBuiltin<"__builtin_cce_vmov_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128bf16_m : ClangBuiltin<"__builtin_cce_vmov_v128bf16_m">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v128bf16_ty, llvm_v128bf16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v64u32_m : ClangBuiltin<"__builtin_cce_vmov_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v64s32_m : ClangBuiltin<"__builtin_cce_vmov_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmov_v64f32_m : ClangBuiltin<"__builtin_cce_vmov_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmov_v256u8 : ClangBuiltin<"__builtin_cce_vmov_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty], [IntrNoMem]>;
  def int_hivm_vmov_v256s8 : ClangBuiltin<"__builtin_cce_vmov_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128u16 : ClangBuiltin<"__builtin_cce_vmov_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128s16 : ClangBuiltin<"__builtin_cce_vmov_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128f16 : ClangBuiltin<"__builtin_cce_vmov_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty], [IntrNoMem]>;
  def int_hivm_vmov_v128bf16 : ClangBuiltin<"__builtin_cce_vmov_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v128bf16_ty], [IntrNoMem]>;
  def int_hivm_vmov_v64u32 : ClangBuiltin<"__builtin_cce_vmov_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty], [IntrNoMem]>;
  def int_hivm_vmov_v64s32 : ClangBuiltin<"__builtin_cce_vmov_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty], [IntrNoMem]>;
  def int_hivm_vmov_v32s64 : ClangBuiltin<"__builtin_cce_vmov_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_v32i64_ty], [IntrNoMem]>;
  def int_hivm_vmov_v64f32 : ClangBuiltin<"__builtin_cce_vmov_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty], [IntrNoMem]>;

  // MOVVP
  def int_hivm_movvp_v128u16 : ClangBuiltin<"__builtin_cce_movvp_v128u16">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_movvp_v128s16 : ClangBuiltin<"__builtin_cce_movvp_v128s16">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_movvp_v64u32 : ClangBuiltin<"__builtin_cce_movvp_v64u32">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_movvp_v64s32 : ClangBuiltin<"__builtin_cce_movvp_v64s32">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VSELR
  // VL = 2048 bit
  def int_hivm_vselr_v256u8 :  ClangBuiltin<"__builtin_cce_vselr_v256u8">,
     Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty], [IntrNoMem]>;
  def int_hivm_vselr_v256s8 :  ClangBuiltin<"__builtin_cce_vselr_v256s8">,
     Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty], [IntrNoMem]>;
  def int_hivm_vselr_v128u16 :  ClangBuiltin<"__builtin_cce_vselr_v128u16">,
     Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;
  def int_hivm_vselr_v128s16 :  ClangBuiltin<"__builtin_cce_vselr_v128s16">,
     Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty], [IntrNoMem]>;
  def int_hivm_vselr_v64u32 :  ClangBuiltin<"__builtin_cce_vselr_v64u32">,
     Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty], [IntrNoMem]>;
  def int_hivm_vselr_v64s32 :  ClangBuiltin<"__builtin_cce_vselr_v64s32">,
     Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty], [IntrNoMem]>;
  def int_hivm_vselr_v128f16 :  ClangBuiltin<"__builtin_cce_vselr_v128f16">,
     Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128i16_ty], [IntrNoMem]>;

  // VDUPS
  // VL = 2048 bit
  def int_hivm_vdups_v256u8 : ClangBuiltin<"__builtin_cce_vdups_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v256s8 : ClangBuiltin<"__builtin_cce_vdups_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v128u16 : ClangBuiltin<"__builtin_cce_vdups_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v128s16 : ClangBuiltin<"__builtin_cce_vdups_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v128f16 : ClangBuiltin<"__builtin_cce_vdups_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v64u32 : ClangBuiltin<"__builtin_cce_vdups_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v64s32 : ClangBuiltin<"__builtin_cce_vdups_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v64f32 : ClangBuiltin<"__builtin_cce_vdups_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vdups_v256u8_z : ClangBuiltin<"__builtin_cce_vdups_v256u8_z">,
    Intrinsic<[llvm_v256i8_ty], [llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v256s8_z : ClangBuiltin<"__builtin_cce_vdups_v256s8_z">,
    Intrinsic<[llvm_v256i8_ty], [llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v128u16_z : ClangBuiltin<"__builtin_cce_vdups_v128u16_z">,
    Intrinsic<[llvm_v128i16_ty], [llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v128s16_z : ClangBuiltin<"__builtin_cce_vdups_v128s16_z">,
    Intrinsic<[llvm_v128i16_ty], [llvm_i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v128f16_z : ClangBuiltin<"__builtin_cce_vdups_v128f16_z">,
    Intrinsic<[llvm_v128f16_ty], [llvm_half_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v64u32_z : ClangBuiltin<"__builtin_cce_vdups_v64u32_z">,
    Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v64s32_z : ClangBuiltin<"__builtin_cce_vdups_v64s32_z">,
    Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdups_v64f32_z : ClangBuiltin<"__builtin_cce_vdups_v64f32_z">,
    Intrinsic<[llvm_v64f32_ty], [llvm_float_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // VDUP
  // VL = 2048 bit
  def int_hivm_vdup_v256u8 : ClangBuiltin<"__builtin_cce_vdup_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v256s8 : ClangBuiltin<"__builtin_cce_vdup_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128u16 : ClangBuiltin<"__builtin_cce_vdup_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128s16 : ClangBuiltin<"__builtin_cce_vdup_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128f16 : ClangBuiltin<"__builtin_cce_vdup_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128bf16 : ClangBuiltin<"__builtin_cce_vdup_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v128bf16_ty, llvm_v128bf16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v64u32 : ClangBuiltin<"__builtin_cce_vdup_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v64s32 : ClangBuiltin<"__builtin_cce_vdup_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v64f32 : ClangBuiltin<"__builtin_cce_vdup_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vdup_v256u8_z : ClangBuiltin<"__builtin_cce_vdup_v256u8_z">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v256s8_z : ClangBuiltin<"__builtin_cce_vdup_v256s8_z">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128u16_z : ClangBuiltin<"__builtin_cce_vdup_v128u16_z">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128s16_z : ClangBuiltin<"__builtin_cce_vdup_v128s16_z">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128bf16_z : ClangBuiltin<"__builtin_cce_vdup_v128bf16_z">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v128bf16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v128f16_z : ClangBuiltin<"__builtin_cce_vdup_v128f16_z">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v64u32_z : ClangBuiltin<"__builtin_cce_vdup_v64u32_z">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v64s32_z : ClangBuiltin<"__builtin_cce_vdup_v64s32_z">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdup_v64f32_z : ClangBuiltin<"__builtin_cce_vdup_v64f32_z">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;


  // VDUPI
  // VL = 2048 bit
  def int_hivm_vdupi_v256u8 : ClangBuiltin<"__builtin_cce_vdupi_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupi_v256s8 : ClangBuiltin<"__builtin_cce_vdupi_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vdupi_v128u16_x : ClangBuiltin<"__builtin_cce_vdupi_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupi_v128s16_x : ClangBuiltin<"__builtin_cce_vdupi_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupi_v128u16_m : ClangBuiltin<"__builtin_cce_vdupi_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupi_v128s16_m: ClangBuiltin<"__builtin_cce_vdupi_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VDUPM
  // VL = 2048 bit
  def int_hivm_vdupm_v256u8 : ClangBuiltin<"__builtin_cce_vdupm_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v256s8 : ClangBuiltin<"__builtin_cce_vdupm_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128u16 : ClangBuiltin<"__builtin_cce_vdupm_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128s16 : ClangBuiltin<"__builtin_cce_vdupm_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128bf16 : ClangBuiltin<"__builtin_cce_vdupm_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v128bf16_ty, llvm_v128bf16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128f16 : ClangBuiltin<"__builtin_cce_vdupm_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v64u32 : ClangBuiltin<"__builtin_cce_vdupm_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v64s32 : ClangBuiltin<"__builtin_cce_vdupm_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v64f32 : ClangBuiltin<"__builtin_cce_vdupm_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vdupm_v256u8_z : ClangBuiltin<"__builtin_cce_vdupm_v256u8_z">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v256s8_z : ClangBuiltin<"__builtin_cce_vdupm_v256s8_z">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128u16_z : ClangBuiltin<"__builtin_cce_vdupm_v128u16_z">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128s16_z : ClangBuiltin<"__builtin_cce_vdupm_v128s16_z">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128f16_z : ClangBuiltin<"__builtin_cce_vdupm_v128f16_z">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v128bf16_z : ClangBuiltin<"__builtin_cce_vdupm_v128bf16_z">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v128bf16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v64u32_z : ClangBuiltin<"__builtin_cce_vdupm_v64u32_z">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v64s32_z : ClangBuiltin<"__builtin_cce_vdupm_v64s32_z">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vdupm_v64f32_z : ClangBuiltin<"__builtin_cce_vdupm_v64f32_z">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // VPACK
  // VL = 2048 bit
  def int_hivm_vpack_u162u8_m : ClangBuiltin<"__builtin_cce_vpack_u162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vpack_s162u8_m : ClangBuiltin<"__builtin_cce_vpack_s162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vpack_u322u16_m : ClangBuiltin<"__builtin_cce_vpack_u322u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vpack_s322u16_m : ClangBuiltin<"__builtin_cce_vpack_s322u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vpack_u162u8_x : ClangBuiltin<"__builtin_cce_vpack_u162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vpack_s162u8_x : ClangBuiltin<"__builtin_cce_vpack_s162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vpack_u322u16_x : ClangBuiltin<"__builtin_cce_vpack_u322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vpack_s322u16_x : ClangBuiltin<"__builtin_cce_vpack_s322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VZUNPACK && VSUNPACK
  // VL = 2048 bit
  def int_hivm_vzunpack_u82u16 : ClangBuiltin<"__builtin_cce_vzunpack_u82u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vsunpack_s82s16 : ClangBuiltin<"__builtin_cce_vsunpack_s82s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vzunpack_u162u32 : ClangBuiltin<"__builtin_cce_vzunpack_u162u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vsunpack_s162s32 : ClangBuiltin<"__builtin_cce_vsunpack_s162s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;

  // VBCNT
  // VL = 2048 bit
  def int_hivm_vbcnt_v256s8_m : ClangBuiltin<"__builtin_cce_vbcnt_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v128s16_m : ClangBuiltin<"__builtin_cce_vbcnt_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v64s32_m : ClangBuiltin<"__builtin_cce_vbcnt_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v256u8_m : ClangBuiltin<"__builtin_cce_vbcnt_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v128u16_m : ClangBuiltin<"__builtin_cce_vbcnt_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v64u32_m : ClangBuiltin<"__builtin_cce_vbcnt_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vbcnt_v256s8_x : ClangBuiltin<"__builtin_cce_vbcnt_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v128s16_x : ClangBuiltin<"__builtin_cce_vbcnt_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v64s32_x : ClangBuiltin<"__builtin_cce_vbcnt_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v256u8_x : ClangBuiltin<"__builtin_cce_vbcnt_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v128u16_x : ClangBuiltin<"__builtin_cce_vbcnt_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vbcnt_v64u32_x : ClangBuiltin<"__builtin_cce_vbcnt_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VABS
  // VL = 2048 bit
  def int_hivm_vabs_v256s8_m : ClangBuiltin<"__builtin_cce_vabs_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v128s16_m : ClangBuiltin<"__builtin_cce_vabs_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v64s32_m : ClangBuiltin<"__builtin_cce_vabs_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v128f16_m : ClangBuiltin<"__builtin_cce_vabs_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v64f32_m : ClangBuiltin<"__builtin_cce_vabs_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vabs_v256s8_x : ClangBuiltin<"__builtin_cce_vabs_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v128s16_x : ClangBuiltin<"__builtin_cce_vabs_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v64s32_x : ClangBuiltin<"__builtin_cce_vabs_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v128f16_x : ClangBuiltin<"__builtin_cce_vabs_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vabs_v64f32_x : ClangBuiltin<"__builtin_cce_vabs_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCLS
  // VL = 2048 bit
  def int_hivm_vcls_v256s8_m : ClangBuiltin<"__builtin_cce_vcls_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v128s16_m : ClangBuiltin<"__builtin_cce_vcls_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v64s32_m : ClangBuiltin<"__builtin_cce_vcls_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v256u8_m : ClangBuiltin<"__builtin_cce_vcls_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v128u16_m : ClangBuiltin<"__builtin_cce_vcls_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v64u32_m : ClangBuiltin<"__builtin_cce_vcls_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcls_v256s8_x : ClangBuiltin<"__builtin_cce_vcls_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v128s16_x : ClangBuiltin<"__builtin_cce_vcls_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v64s32_x : ClangBuiltin<"__builtin_cce_vcls_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v256u8_x : ClangBuiltin<"__builtin_cce_vcls_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v128u16_x : ClangBuiltin<"__builtin_cce_vcls_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcls_v64u32_x : ClangBuiltin<"__builtin_cce_vcls_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VNEG
  // VL = 2048 bit
  def int_hivm_vneg_v256s8_m : ClangBuiltin<"__builtin_cce_vneg_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v128s16_m : ClangBuiltin<"__builtin_cce_vneg_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v64s32_m : ClangBuiltin<"__builtin_cce_vneg_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v128f16_m : ClangBuiltin<"__builtin_cce_vneg_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v64f32_m : ClangBuiltin<"__builtin_cce_vneg_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vneg_v256s8_x : ClangBuiltin<"__builtin_cce_vneg_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v128s16_x : ClangBuiltin<"__builtin_cce_vneg_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v64s32_x : ClangBuiltin<"__builtin_cce_vneg_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v128f16_x : ClangBuiltin<"__builtin_cce_vneg_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vneg_v64f32_x : ClangBuiltin<"__builtin_cce_vneg_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCADD
  // VL = 2048 bit
  def int_hivm_vcadd_v256s8_m : ClangBuiltin<"__builtin_cce_vcadd_v256s8_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v128s16_m : ClangBuiltin<"__builtin_cce_vcadd_v128s16_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v64s32_m : ClangBuiltin<"__builtin_cce_vcadd_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v256u8_m : ClangBuiltin<"__builtin_cce_vcadd_v256u8_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v128u16_m : ClangBuiltin<"__builtin_cce_vcadd_v128u16_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v64u32_m : ClangBuiltin<"__builtin_cce_vcadd_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v128f16_m : ClangBuiltin<"__builtin_cce_vcadd_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v64f32_m : ClangBuiltin<"__builtin_cce_vcadd_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcadd_v256s8_x : ClangBuiltin<"__builtin_cce_vcadd_v256s8_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v128s16_x : ClangBuiltin<"__builtin_cce_vcadd_v128s16_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v64s32_x : ClangBuiltin<"__builtin_cce_vcadd_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v256u8_x : ClangBuiltin<"__builtin_cce_vcadd_v256u8_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v128u16_x : ClangBuiltin<"__builtin_cce_vcadd_v128u16_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v64u32_x : ClangBuiltin<"__builtin_cce_vcadd_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v128f16_x : ClangBuiltin<"__builtin_cce_vcadd_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcadd_v64f32_x : ClangBuiltin<"__builtin_cce_vcadd_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCMAX
  // VL = 2048 bit
  def int_hivm_vcmax_v256s8_m : ClangBuiltin<"__builtin_cce_vcmax_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v128s16_m : ClangBuiltin<"__builtin_cce_vcmax_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v64s32_m : ClangBuiltin<"__builtin_cce_vcmax_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v256u8_m : ClangBuiltin<"__builtin_cce_vcmax_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v128u16_m : ClangBuiltin<"__builtin_cce_vcmax_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v64u32_m : ClangBuiltin<"__builtin_cce_vcmax_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v128f16_m : ClangBuiltin<"__builtin_cce_vcmax_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v64f32_m : ClangBuiltin<"__builtin_cce_vcmax_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmax_v256s8_x : ClangBuiltin<"__builtin_cce_vcmax_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v128s16_x : ClangBuiltin<"__builtin_cce_vcmax_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v64s32_x : ClangBuiltin<"__builtin_cce_vcmax_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v256u8_x : ClangBuiltin<"__builtin_cce_vcmax_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v128u16_x : ClangBuiltin<"__builtin_cce_vcmax_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v64u32_x : ClangBuiltin<"__builtin_cce_vcmax_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v128f16_x : ClangBuiltin<"__builtin_cce_vcmax_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmax_v64f32_x : ClangBuiltin<"__builtin_cce_vcmax_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCMIN
  // VL = 2048 bit
  def int_hivm_vcmin_v256s8_m : ClangBuiltin<"__builtin_cce_vcmin_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v128s16_m : ClangBuiltin<"__builtin_cce_vcmin_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v64s32_m : ClangBuiltin<"__builtin_cce_vcmin_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v256u8_m : ClangBuiltin<"__builtin_cce_vcmin_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v128u16_m : ClangBuiltin<"__builtin_cce_vcmin_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v64u32_m : ClangBuiltin<"__builtin_cce_vcmin_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v128f16_m : ClangBuiltin<"__builtin_cce_vcmin_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v64f32_m : ClangBuiltin<"__builtin_cce_vcmin_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmin_v256s8_x : ClangBuiltin<"__builtin_cce_vcmin_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v128s16_x : ClangBuiltin<"__builtin_cce_vcmin_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v64s32_x : ClangBuiltin<"__builtin_cce_vcmin_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v256u8_x : ClangBuiltin<"__builtin_cce_vcmin_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v128u16_x : ClangBuiltin<"__builtin_cce_vcmin_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v64u32_x : ClangBuiltin<"__builtin_cce_vcmin_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v128f16_x : ClangBuiltin<"__builtin_cce_vcmin_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmin_v64f32_x : ClangBuiltin<"__builtin_cce_vcmin_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSQZ, basically VSQZ implicitly define the SPR SQZN, we need to use side effect here
  // However, SQZN is only used by VSTUR, so the data dependence of SQZN is naturally guaranteed by the dependence of V register
  // VL = 2048 bit
  def int_hivm_vsqz_v256s8_m : ClangBuiltin<"__builtin_cce_vsqz_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v128s16_m : ClangBuiltin<"__builtin_cce_vsqz_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v64s32_m : ClangBuiltin<"__builtin_cce_vsqz_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v256u8_m : ClangBuiltin<"__builtin_cce_vsqz_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v128u16_m : ClangBuiltin<"__builtin_cce_vsqz_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v64u32_m : ClangBuiltin<"__builtin_cce_vsqz_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v128f16_m : ClangBuiltin<"__builtin_cce_vsqz_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v64f32_m : ClangBuiltin<"__builtin_cce_vsqz_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrHasSideEffects]>;

  def int_hivm_vsqz_v256s8_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v256s8_x_v300">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v128s16_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v128s16_x_v300">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v64s32_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v64s32_x_v300">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v256u8_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v256u8_x_v300">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v128u16_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v128u16_x_v300">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v64u32_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v64u32_x_v300">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v128f16_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v128f16_x_v300">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vsqz_v64f32_x_v300 : ClangBuiltin<"__builtin_cce_vsqz_v64f32_x_v300">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  // VUSQZ
  // VL = 2048 bit
  def int_hivm_vusqz_v256s8_m : ClangBuiltin<"__builtin_cce_vusqz_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vusqz_v128s16_m : ClangBuiltin<"__builtin_cce_vusqz_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vusqz_v64s32_m : ClangBuiltin<"__builtin_cce_vusqz_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vusqz_v256u8_m : ClangBuiltin<"__builtin_cce_vusqz_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vusqz_v128u16_m : ClangBuiltin<"__builtin_cce_vusqz_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vusqz_v64u32_m : ClangBuiltin<"__builtin_cce_vusqz_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VADDS
  // VL = 2048 bit
  def int_hivm_vadds_v256s8_m : ClangBuiltin<"__builtin_cce_vadds_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v128s16_m : ClangBuiltin<"__builtin_cce_vadds_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v64s32_m : ClangBuiltin<"__builtin_cce_vadds_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v256u8_m : ClangBuiltin<"__builtin_cce_vadds_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v128u16_m : ClangBuiltin<"__builtin_cce_vadds_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v64u32_m : ClangBuiltin<"__builtin_cce_vadds_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v64f32_m : ClangBuiltin<"__builtin_cce_vadds_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v128f16_m : ClangBuiltin<"__builtin_cce_vadds_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vadds_v256s8_x : ClangBuiltin<"__builtin_cce_vadds_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v128s16_x : ClangBuiltin<"__builtin_cce_vadds_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v64s32_x : ClangBuiltin<"__builtin_cce_vadds_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v256u8_x : ClangBuiltin<"__builtin_cce_vadds_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v128u16_x : ClangBuiltin<"__builtin_cce_vadds_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v64u32_x : ClangBuiltin<"__builtin_cce_vadds_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v64f32_x : ClangBuiltin<"__builtin_cce_vadds_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vadds_v128f16_x : ClangBuiltin<"__builtin_cce_vadds_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMULS
  // VL = 2048 bit
  def int_hivm_vmuls_v256s8_m : ClangBuiltin<"__builtin_cce_vmuls_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v128s16_m : ClangBuiltin<"__builtin_cce_vmuls_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v64s32_m : ClangBuiltin<"__builtin_cce_vmuls_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v256u8_m : ClangBuiltin<"__builtin_cce_vmuls_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v128u16_m : ClangBuiltin<"__builtin_cce_vmuls_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v64u32_m : ClangBuiltin<"__builtin_cce_vmuls_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v64f32_m : ClangBuiltin<"__builtin_cce_vmuls_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v128f16_m : ClangBuiltin<"__builtin_cce_vmuls_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmuls_v256s8_x : ClangBuiltin<"__builtin_cce_vmuls_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v128s16_x : ClangBuiltin<"__builtin_cce_vmuls_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v64s32_x : ClangBuiltin<"__builtin_cce_vmuls_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v256u8_x : ClangBuiltin<"__builtin_cce_vmuls_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v128u16_x : ClangBuiltin<"__builtin_cce_vmuls_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v64u32_x : ClangBuiltin<"__builtin_cce_vmuls_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v64f32_x : ClangBuiltin<"__builtin_cce_vmuls_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmuls_v128f16_x : ClangBuiltin<"__builtin_cce_vmuls_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VLRELU
  // VL = 2048 bit
  def int_hivm_vlrelu_v64f32_m : ClangBuiltin<"__builtin_cce_vlrelu_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vlrelu_v128f16_m : ClangBuiltin<"__builtin_cce_vlrelu_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vlrelu_v64f32_x : ClangBuiltin<"__builtin_cce_vlrelu_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vlrelu_v128f16_x : ClangBuiltin<"__builtin_cce_vlrelu_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMAXS
  // VL = 2048 bit
  def int_hivm_vmaxs_v256s8_m : ClangBuiltin<"__builtin_cce_vmaxs_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v128s16_m : ClangBuiltin<"__builtin_cce_vmaxs_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v64s32_m : ClangBuiltin<"__builtin_cce_vmaxs_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v256u8_m : ClangBuiltin<"__builtin_cce_vmaxs_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v128u16_m : ClangBuiltin<"__builtin_cce_vmaxs_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v64u32_m : ClangBuiltin<"__builtin_cce_vmaxs_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v128f16_m : ClangBuiltin<"__builtin_cce_vmaxs_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v64f32_m : ClangBuiltin<"__builtin_cce_vmaxs_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmaxs_v256s8_x : ClangBuiltin<"__builtin_cce_vmaxs_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v128s16_x : ClangBuiltin<"__builtin_cce_vmaxs_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v64s32_x : ClangBuiltin<"__builtin_cce_vmaxs_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v256u8_x : ClangBuiltin<"__builtin_cce_vmaxs_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v128u16_x : ClangBuiltin<"__builtin_cce_vmaxs_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v64u32_x : ClangBuiltin<"__builtin_cce_vmaxs_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v128f16_x : ClangBuiltin<"__builtin_cce_vmaxs_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmaxs_v64f32_x : ClangBuiltin<"__builtin_cce_vmaxs_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VMINS
  // VL = 2048 bit
  def int_hivm_vmins_v256s8_m : ClangBuiltin<"__builtin_cce_vmins_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v128s16_m : ClangBuiltin<"__builtin_cce_vmins_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v64s32_m : ClangBuiltin<"__builtin_cce_vmins_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v256u8_m : ClangBuiltin<"__builtin_cce_vmins_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v128u16_m : ClangBuiltin<"__builtin_cce_vmins_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v64u32_m : ClangBuiltin<"__builtin_cce_vmins_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v128f16_m : ClangBuiltin<"__builtin_cce_vmins_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v64f32_m : ClangBuiltin<"__builtin_cce_vmins_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vmins_v256s8_x : ClangBuiltin<"__builtin_cce_vmins_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v128s16_x : ClangBuiltin<"__builtin_cce_vmins_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v64s32_x : ClangBuiltin<"__builtin_cce_vmins_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v256u8_x : ClangBuiltin<"__builtin_cce_vmins_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v128u16_x : ClangBuiltin<"__builtin_cce_vmins_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v64u32_x : ClangBuiltin<"__builtin_cce_vmins_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v128f16_x : ClangBuiltin<"__builtin_cce_vmins_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vmins_v64f32_x : ClangBuiltin<"__builtin_cce_vmins_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSHLS
  // VL = 2048 bit
  def int_hivm_vshls_v256u8_m : ClangBuiltin<"__builtin_cce_vshls_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v128s16_m : ClangBuiltin<"__builtin_cce_vshls_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v128u16_m : ClangBuiltin<"__builtin_cce_vshls_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v64s32_m : ClangBuiltin<"__builtin_cce_vshls_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v64u32_m : ClangBuiltin<"__builtin_cce_vshls_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vshls_v256u8_x : ClangBuiltin<"__builtin_cce_vshls_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v256s8_x : ClangBuiltin<"__builtin_cce_vshls_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v128s16_x : ClangBuiltin<"__builtin_cce_vshls_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v128u16_x : ClangBuiltin<"__builtin_cce_vshls_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v64s32_x : ClangBuiltin<"__builtin_cce_vshls_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshls_v64u32_x : ClangBuiltin<"__builtin_cce_vshls_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VSHRS
  // VL = 2048 bit
  def int_hivm_vshrs_v256u8_m : ClangBuiltin<"__builtin_cce_vshrs_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v128s16_m : ClangBuiltin<"__builtin_cce_vshrs_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v128u16_m : ClangBuiltin<"__builtin_cce_vshrs_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v64s32_m : ClangBuiltin<"__builtin_cce_vshrs_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v64u32_m : ClangBuiltin<"__builtin_cce_vshrs_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vshrs_v256u8_x : ClangBuiltin<"__builtin_cce_vshrs_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v256s8_x : ClangBuiltin<"__builtin_cce_vshrs_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v128s16_x : ClangBuiltin<"__builtin_cce_vshrs_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v128u16_x : ClangBuiltin<"__builtin_cce_vshrs_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v64s32_x : ClangBuiltin<"__builtin_cce_vshrs_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vshrs_v64u32_x : ClangBuiltin<"__builtin_cce_vshrs_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCI
  def int_hivm_vci_v64s32 : ClangBuiltin<"__builtin_cce_vci_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
  def int_hivm_vci_v128s16 : ClangBuiltin<"__builtin_cce_vci_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_i16_ty, llvm_i32_ty], [IntrReadMem]>;
  def int_hivm_vci_v256s8 : ClangBuiltin<"__builtin_cce_vci_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_i16_ty, llvm_i32_ty], [IntrReadMem]>;
  def int_hivm_vci_v64f32 : ClangBuiltin<"__builtin_cce_vci_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrReadMem]>;
  def int_hivm_vci_v128f16 : ClangBuiltin<"__builtin_cce_vci_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_i16_ty, llvm_i32_ty], [IntrReadMem]>;

  def int_hivm_vci_v64f32_f32 : ClangBuiltin<"__builtin_cce_vci_v64f32_f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_float_ty, llvm_i32_ty], [IntrReadMem]>;
  def int_hivm_vci_v128f16_f16 : ClangBuiltin<"__builtin_cce_vci_v128f16_f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_half_ty, llvm_i32_ty], [IntrReadMem]>;

  // VLDx1
  def int_hivm_vldx1_v32u64 : ClangBuiltin<"__builtin_cce_vldx1_v32u64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v32s64 : ClangBuiltin<"__builtin_cce_vldx1_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v64s32 : ClangBuiltin<"__builtin_cce_vldx1_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v64u32 : ClangBuiltin<"__builtin_cce_vldx1_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v128s16 : ClangBuiltin<"__builtin_cce_vldx1_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v128u16 : ClangBuiltin<"__builtin_cce_vldx1_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v256s8 : ClangBuiltin<"__builtin_cce_vldx1_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v256u8 : ClangBuiltin<"__builtin_cce_vldx1_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v64f32 : ClangBuiltin<"__builtin_cce_vldx1_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v128f16 : ClangBuiltin<"__builtin_cce_vldx1_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldx1_v128bf16 : ClangBuiltin<"__builtin_cce_vldx1_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VLDONCEx1
  def int_hivm_vldoncex1_v32s64 : ClangBuiltin<"__builtin_cce_vldoncex1_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v32u64 : ClangBuiltin<"__builtin_cce_vldoncex1_v32u64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v64s32 : ClangBuiltin<"__builtin_cce_vldoncex1_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v64u32 : ClangBuiltin<"__builtin_cce_vldoncex1_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v128s16 : ClangBuiltin<"__builtin_cce_vldoncex1_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v128u16 : ClangBuiltin<"__builtin_cce_vldoncex1_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v256s8 : ClangBuiltin<"__builtin_cce_vldoncex1_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v256u8 : ClangBuiltin<"__builtin_cce_vldoncex1_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v64f32 : ClangBuiltin<"__builtin_cce_vldoncex1_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldoncex1_v128f16 : ClangBuiltin<"__builtin_cce_vldoncex1_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDx2
  def int_hivm_vldx2_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldx2_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<0>, NoCapture<0>]>;
  def int_hivm_vldx2_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldx2_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v128bf16_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
                                        //[IntrArgMemOnly, ReadOnly<0>, NoCapture<0>]>;

  // VLDONCEx2
  def int_hivm_vldoncex2_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;
  def int_hivm_vldoncex2_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty],
                                        [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, IntrReadMem]>;

  // VSTx1
  def int_hivm_vstx1_v32u64 : ClangBuiltin<"__builtin_cce_vstx1_v32u64">,
    Intrinsic<[], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v32s64 : ClangBuiltin<"__builtin_cce_vstx1_v32s64">,
    Intrinsic<[], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v64s32 : ClangBuiltin<"__builtin_cce_vstx1_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v64u32 : ClangBuiltin<"__builtin_cce_vstx1_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v128s16 : ClangBuiltin<"__builtin_cce_vstx1_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v128u16 : ClangBuiltin<"__builtin_cce_vstx1_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v256s8 : ClangBuiltin<"__builtin_cce_vstx1_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v256u8 : ClangBuiltin<"__builtin_cce_vstx1_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v64f32 : ClangBuiltin<"__builtin_cce_vstx1_v64f32">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v128f16 : ClangBuiltin<"__builtin_cce_vstx1_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstx1_v128bf16 : ClangBuiltin<"__builtin_cce_vstx1_v128bf16">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  // VSTx2
  def int_hivm_vstx2_v64s32 : ClangBuiltin<"__builtin_cce_vstx2_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v64u32 : ClangBuiltin<"__builtin_cce_vstx2_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v128s16 : ClangBuiltin<"__builtin_cce_vstx2_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v128u16 : ClangBuiltin<"__builtin_cce_vstx2_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v256s8 : ClangBuiltin<"__builtin_cce_vstx2_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v256u8 : ClangBuiltin<"__builtin_cce_vstx2_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v128f16 : ClangBuiltin<"__builtin_cce_vstx2_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstx2_v128bf16 : ClangBuiltin<"__builtin_cce_vstx2_v128bf16">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_v128bf16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;

  // VLDSx1, Pre mode
  def int_hivm_vldsx1_v32u64 : ClangBuiltin<"__builtin_cce_vldsx1_v32u64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v32s64 : ClangBuiltin<"__builtin_cce_vldsx1_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v64s32 : ClangBuiltin<"__builtin_cce_vldsx1_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v64u32 : ClangBuiltin<"__builtin_cce_vldsx1_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v128s16 : ClangBuiltin<"__builtin_cce_vldsx1_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v128u16 : ClangBuiltin<"__builtin_cce_vldsx1_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v256s8 : ClangBuiltin<"__builtin_cce_vldsx1_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v256u8 : ClangBuiltin<"__builtin_cce_vldsx1_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v64f32 : ClangBuiltin<"__builtin_cce_vldsx1_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v128f16 : ClangBuiltin<"__builtin_cce_vldsx1_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_v128bf16 : ClangBuiltin<"__builtin_cce_vldsx1_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDSx2, Pre mode
  def int_hivm_vldsx2_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v128bf16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDSx1, Post mode
  def int_hivm_vldsx1_post_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx1_post_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_ptr_ty6],
                                                [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                                [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDSx2, Post mode
  def int_hivm_vldsx2_post_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldsx2_post_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v128bf16_ty, llvm_ptr_ty6],
                                                [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                                [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VSLDB, Pre mode
  def int_hivm_vsldb_v32s64 : ClangBuiltin<"__builtin_cce_vsldb_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v64s32 : ClangBuiltin<"__builtin_cce_vsldb_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v64u32 : ClangBuiltin<"__builtin_cce_vsldb_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v128s16 : ClangBuiltin<"__builtin_cce_vsldb_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v128u16 : ClangBuiltin<"__builtin_cce_vsldb_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v256s8 : ClangBuiltin<"__builtin_cce_vsldb_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v256u8 : ClangBuiltin<"__builtin_cce_vsldb_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v64f32 : ClangBuiltin<"__builtin_cce_vsldb_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v128f16 : ClangBuiltin<"__builtin_cce_vsldb_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_v128bf16 : ClangBuiltin<"__builtin_cce_vsldb_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VSLDB, Post mode
  def int_hivm_vsldb_post_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsldb_post_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VLDIx1, Pre mode
  def int_hivm_vldix1_v32s64 : ClangBuiltin<"__builtin_cce_vldix1_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v32u64 : ClangBuiltin<"__builtin_cce_vldix1_v32u64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v64s32 : ClangBuiltin<"__builtin_cce_vldix1_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v64u32 : ClangBuiltin<"__builtin_cce_vldix1_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v128s16 : ClangBuiltin<"__builtin_cce_vldix1_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v128u16 : ClangBuiltin<"__builtin_cce_vldix1_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v256s8 : ClangBuiltin<"__builtin_cce_vldix1_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v256u8 : ClangBuiltin<"__builtin_cce_vldix1_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v64f32 : ClangBuiltin<"__builtin_cce_vldix1_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v128f16 : ClangBuiltin<"__builtin_cce_vldix1_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_v128bf16 : ClangBuiltin<"__builtin_cce_vldix1_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDIx2, Pre mode
  def int_hivm_vldix2_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty],
                                         [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty],
                                          [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                          [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v128bf16_ty],
                                           [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                           [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDIx1, Post mode
  def int_hivm_vldix1_post_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix1_post_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_ptr_ty6],
                                                [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                                [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDIx2, Post mode
  def int_hivm_vldix2_post_v32s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v32u64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i64_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v64s32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v64u32 : Intrinsic<[llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v128s16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v128u16 : Intrinsic<[llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v256s8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v256u8 : Intrinsic<[llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v64f32 : Intrinsic<[llvm_v64f32_ty, llvm_v64f32_ty, llvm_ptr_ty6],
                                              [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v128f16 : Intrinsic<[llvm_v128f16_ty, llvm_v128f16_ty, llvm_ptr_ty6],
                                               [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                               [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldix2_post_v128bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v128bf16_ty, llvm_ptr_ty6],
                                                [llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                                                [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VSTSx1, Pre mode
  def int_hivm_vstsx1_v32u64 : ClangBuiltin<"__builtin_cce_vstsx1_v32u64">,
    Intrinsic<[], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v32s64 : ClangBuiltin<"__builtin_cce_vstsx1_v32s64">,
    Intrinsic<[], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v64s32 : ClangBuiltin<"__builtin_cce_vstsx1_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v64u32 : ClangBuiltin<"__builtin_cce_vstsx1_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v128s16 : ClangBuiltin<"__builtin_cce_vstsx1_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v128u16 : ClangBuiltin<"__builtin_cce_vstsx1_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v256s8 : ClangBuiltin<"__builtin_cce_vstsx1_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v256u8 : ClangBuiltin<"__builtin_cce_vstsx1_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v64f32 : ClangBuiltin<"__builtin_cce_vstsx1_v64f32">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v128f16 : ClangBuiltin<"__builtin_cce_vstsx1_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_v128bf16 : ClangBuiltin<"__builtin_cce_vstsx1_v128bf16">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;

  // VSTSx1, Post mode
  def int_hivm_vstsx1_post_v32u64 : ClangBuiltin<"__builtin_cce_vstsx1_post_v32u64">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v32s64 : ClangBuiltin<"__builtin_cce_vstsx1_post_v32s64">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v64s32 : ClangBuiltin<"__builtin_cce_vstsx1_post_v64s32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v64u32 : ClangBuiltin<"__builtin_cce_vstsx1_post_v64u32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v128s16 : ClangBuiltin<"__builtin_cce_vstsx1_post_v128s16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v128u16 : ClangBuiltin<"__builtin_cce_vstsx1_post_v128u16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v256s8 : ClangBuiltin<"__builtin_cce_vstsx1_post_v256s8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v256u8 : ClangBuiltin<"__builtin_cce_vstsx1_post_v256u8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v64f32 : ClangBuiltin<"__builtin_cce_vstsx1_post_v64f32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v128f16 : ClangBuiltin<"__builtin_cce_vstsx1_post_v128f16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstsx1_post_v128bf16 : ClangBuiltin<"__builtin_cce_vstsx1_post_v128bf16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;

  // VSTSx2, Pre mode
  def int_hivm_vstsx2_v128b16 : ClangBuiltin<"__builtin_cce_vstsx2_v128b16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstsx2_v256b8 : ClangBuiltin<"__builtin_cce_vstsx2_v256b8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstsx2_v64b32 : ClangBuiltin<"__builtin_cce_vstsx2_v64b32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;

  // VSTIx1, Pre mode
  def int_hivm_vstix1_v32s64 : ClangBuiltin<"__builtin_cce_vstix1_v32s64">,
    Intrinsic<[], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v32u64 : ClangBuiltin<"__builtin_cce_vstix1_v32u64">,
    Intrinsic<[], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v64s32 : ClangBuiltin<"__builtin_cce_vstix1_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v64u32 : ClangBuiltin<"__builtin_cce_vstix1_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v128s16 : ClangBuiltin<"__builtin_cce_vstix1_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v128u16 : ClangBuiltin<"__builtin_cce_vstix1_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v256s8 : ClangBuiltin<"__builtin_cce_vstix1_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v256u8 : ClangBuiltin<"__builtin_cce_vstix1_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v64f32 : ClangBuiltin<"__builtin_cce_vstix1_v64f32">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v128f16 : ClangBuiltin<"__builtin_cce_vstix1_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_v128bf16 : ClangBuiltin<"__builtin_cce_vstix1_v128bf16">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;

  // VSTIx2, Pre mode
  def int_hivm_vstix2_v128b16 : Intrinsic<[],
              [llvm_v128i16_ty, llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstix2_v256b8 : Intrinsic<[],
              [llvm_v256i8_ty, llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vstix2_v64b32 : Intrinsic<[],
              [llvm_v64i32_ty, llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;

  // VSTIx1, Post mode
  def int_hivm_vstix1_post_v64s32 : ClangBuiltin<"__builtin_cce_vstix1_post_v64s32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v64u32 : ClangBuiltin<"__builtin_cce_vstix1_post_v64u32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v128s16 : ClangBuiltin<"__builtin_cce_vstix1_post_v128s16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v128u16 : ClangBuiltin<"__builtin_cce_vstix1_post_v128u16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v256s8 : ClangBuiltin<"__builtin_cce_vstix1_post_v256s8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v256u8 : ClangBuiltin<"__builtin_cce_vstix1_post_v256u8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v64f32 : ClangBuiltin<"__builtin_cce_vstix1_post_v64f32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v128f16 : ClangBuiltin<"__builtin_cce_vstix1_post_v128f16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v32s64 : ClangBuiltin<"__builtin_cce_vstix1_post_v32s64">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v32u64 : ClangBuiltin<"__builtin_cce_vstix1_post_v32u64">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vstix1_post_v128bf16 : ClangBuiltin<"__builtin_cce_vstix1_post_v128bf16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;

  // VSSTB, Pre mode
  def int_hivm_vsstb_v64s32 : ClangBuiltin<"__builtin_cce_vsstb_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v64u32 : ClangBuiltin<"__builtin_cce_vsstb_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v128s16 : ClangBuiltin<"__builtin_cce_vsstb_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v128u16 : ClangBuiltin<"__builtin_cce_vsstb_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v256s8 : ClangBuiltin<"__builtin_cce_vsstb_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v256u8 : ClangBuiltin<"__builtin_cce_vsstb_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v64f32 : ClangBuiltin<"__builtin_cce_vsstb_v64f32">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v128f16 : ClangBuiltin<"__builtin_cce_vsstb_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_v128bf16 : ClangBuiltin<"__builtin_cce_vsstb_v128bf16">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSSTB, Post mode
  def int_hivm_vsstb_post_v64s32 : ClangBuiltin<"__builtin_cce_vsstb_post_v64s32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v64u32 : ClangBuiltin<"__builtin_cce_vsstb_post_v64u32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v128s16 : ClangBuiltin<"__builtin_cce_vsstb_post_v128s16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v128u16 : ClangBuiltin<"__builtin_cce_vsstb_post_v128u16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v256s8 : ClangBuiltin<"__builtin_cce_vsstb_post_v256s8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v256u8 : ClangBuiltin<"__builtin_cce_vsstb_post_v256u8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v64f32 : ClangBuiltin<"__builtin_cce_vsstb_post_v64f32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v128f16 : ClangBuiltin<"__builtin_cce_vsstb_post_v128f16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsstb_post_v128bf16 : ClangBuiltin<"__builtin_cce_vsstb_post_v128bf16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSCATTER
  def int_hivm_vscatter_v64s32 : ClangBuiltin<"__builtin_cce_vscatter_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v64u32 : ClangBuiltin<"__builtin_cce_vscatter_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v128s16 : ClangBuiltin<"__builtin_cce_vscatter_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v128u16 : ClangBuiltin<"__builtin_cce_vscatter_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v256s8 : ClangBuiltin<"__builtin_cce_vscatter_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v256u8 : ClangBuiltin<"__builtin_cce_vscatter_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v64f32 : ClangBuiltin<"__builtin_cce_vscatter_v64f32">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;
  def int_hivm_vscatter_v128f16 : ClangBuiltin<"__builtin_cce_vscatter_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>]>;

  // VSCATTER_V300
  def int_hivm_vscatter_v64s32_v300 : ClangBuiltin<"__builtin_cce_vscatter_v64s32_v300">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v64u32_v300 : ClangBuiltin<"__builtin_cce_vscatter_v64u32_v300">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v128s16_v300 : ClangBuiltin<"__builtin_cce_vscatter_v128s16_v300">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v128u16_v300 : ClangBuiltin<"__builtin_cce_vscatter_v128u16_v300">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v256s8_v300 : ClangBuiltin<"__builtin_cce_vscatter_v256s8_v300">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v256u8_v300 : ClangBuiltin<"__builtin_cce_vscatter_v256u8_v300">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v64f32_v300 : ClangBuiltin<"__builtin_cce_vscatter_v64f32_v300">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v128f16_v300 : ClangBuiltin<"__builtin_cce_vscatter_v128f16_v300">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vscatter_v128bf16_v300 : ClangBuiltin<"__builtin_cce_vscatter_v128bf16_v300">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_v128i16_ty, llvm_v256i1_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VLDA
  def int_hivm_vlda_s8 : ClangBuiltin<"__builtin_cce_vlda_s8">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_u8 : ClangBuiltin<"__builtin_cce_vlda_u8">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_s16 : ClangBuiltin<"__builtin_cce_vlda_s16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_u16 : ClangBuiltin<"__builtin_cce_vlda_u16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_s32 : ClangBuiltin<"__builtin_cce_vlda_s32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_u32 : ClangBuiltin<"__builtin_cce_vlda_u32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_s64 : ClangBuiltin<"__builtin_cce_vlda_s64">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  def int_hivm_vlda_bf16 : ClangBuiltin<"__builtin_cce_vlda_bf16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_f16 : ClangBuiltin<"__builtin_cce_vlda_f16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vlda_f32 : ClangBuiltin<"__builtin_cce_vlda_f32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  // VLDAS
  def int_hivm_vldas_s8 : ClangBuiltin<"__builtin_cce_vldas_s8">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_u8 : ClangBuiltin<"__builtin_cce_vldas_u8">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_s16 : ClangBuiltin<"__builtin_cce_vldas_s16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_u16 : ClangBuiltin<"__builtin_cce_vldas_u16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_s32 : ClangBuiltin<"__builtin_cce_vldas_s32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_u32 : ClangBuiltin<"__builtin_cce_vldas_u32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_s64 : ClangBuiltin<"__builtin_cce_vldas_s64">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_bf16 : ClangBuiltin<"__builtin_cce_vldas_bf16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_f16 : ClangBuiltin<"__builtin_cce_vldas_f16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;
  def int_hivm_vldas_f32 : ClangBuiltin<"__builtin_cce_vldas_f32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_ptr_ty6], [IntrHasSideEffects]>;

  // VLDU
  def int_hivm_vldu_s8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                   [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                   [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_u8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                   [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                   [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_s16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_u16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_s32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_u32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_f16 : Intrinsic<[llvm_v128f16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldu_f32 : Intrinsic<[llvm_v64f32_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i16_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  def int_hivm_vldu_v300_s8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_u8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                        [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                        [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_s16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_u16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_s32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_u32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_f16 : Intrinsic<[llvm_v128f16_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldu_v300_f32 : Intrinsic<[llvm_v64f32_ty, llvm_v32i8_ty, llvm_v1i32_ty],
                                         [llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                         [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VLDUS
  def int_hivm_vldus_s8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_u8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_s16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_u16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_s32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_u32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_f16 : Intrinsic<[llvm_v128f16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldus_f32 : Intrinsic<[llvm_v64f32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDUS POST
  def int_hivm_vldus_post_s8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_u8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_s16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_u16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_s32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_u32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_f16 : Intrinsic<[llvm_v128f16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldus_post_f32 : Intrinsic<[llvm_v64f32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VLDUI
  def int_hivm_vldui_s8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_u8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_s16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_u16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_s32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_u32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_f16 : Intrinsic<[llvm_v128f16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vldui_f32 : Intrinsic<[llvm_v64f32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VLDUI POST
  def int_hivm_vldui_post_s8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_u8 : Intrinsic<[llvm_v256i8_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                    [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_s16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_u16 : Intrinsic<[llvm_v128i16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_s32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_u32 : Intrinsic<[llvm_v64i32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_s64 : Intrinsic<[llvm_v32i64_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_bf16 : Intrinsic<[llvm_v128bf16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_f16 : Intrinsic<[llvm_v128f16_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vldui_post_f32 : Intrinsic<[llvm_v64f32_ty, llvm_v32i8_ty, llvm_ptr_ty6],
                                     [llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty],
                                     [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VSTU
  def int_hivm_vstu_s8 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_u8 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_s16 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_u16 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_s32 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_u32 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_s64 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v32i64_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_bf16 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_f16 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v128f16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstu_f32 : Intrinsic<[llvm_v32i8_ty, llvm_v1i32_ty],
                                    [llvm_v64f32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTUS
  def int_hivm_vstus_s8 : Intrinsic<[llvm_v32i8_ty],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_u8 : Intrinsic<[llvm_v32i8_ty],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_s16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_u16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_s32 : Intrinsic<[llvm_v32i8_ty],
                                     [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                     [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_s64 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_bf16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_f16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_u32 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_f32 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTUS post
  def int_hivm_vstus_post_s8 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_u8 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_s16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_u16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_s32 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_u32 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_s64 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_bf16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_f16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstus_post_f32 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTUI
  def int_hivm_vstui_s8 : Intrinsic<[llvm_v32i8_ty],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_u8 : Intrinsic<[llvm_v32i8_ty],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_s16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_u16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_s32 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_u32 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_s64 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_bf16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_f16 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_f32 : Intrinsic<[llvm_v32i8_ty],
                                    [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTUI post
  def int_hivm_vstui_post_s8 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_u8 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                   [llvm_v256i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                   [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_s16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_u16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_s32 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_u32 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v64i32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_s64 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v32i64_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_bf16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_f16 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v128f16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstui_post_f32 : Intrinsic<[llvm_v32i8_ty, llvm_ptr_ty6],
                                    [llvm_v64f32_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_v32i8_ty],
                                    [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTA
  def int_hivm_vsta_s8 : ClangBuiltin<"__builtin_cce_vsta_s8">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_u8 : ClangBuiltin<"__builtin_cce_vsta_u8">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_s16 : ClangBuiltin<"__builtin_cce_vsta_s16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_u16 : ClangBuiltin<"__builtin_cce_vsta_u16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_s32 : ClangBuiltin<"__builtin_cce_vsta_s32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_u32 : ClangBuiltin<"__builtin_cce_vsta_u32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_s64 : ClangBuiltin<"__builtin_cce_vsta_s64">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  def int_hivm_vsta_bf16 : ClangBuiltin<"__builtin_cce_vsta_bf16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_f16 : ClangBuiltin<"__builtin_cce_vsta_f16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsta_f32 : ClangBuiltin<"__builtin_cce_vsta_f32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTAI Pre mode
  def int_hivm_vstai_s8 : ClangBuiltin<"__builtin_cce_vstai_s8">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_u8 : ClangBuiltin<"__builtin_cce_vstai_u8">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_s16 : ClangBuiltin<"__builtin_cce_vstai_s16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_u16 : ClangBuiltin<"__builtin_cce_vstai_u16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_s32 : ClangBuiltin<"__builtin_cce_vstai_s32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_u32 : ClangBuiltin<"__builtin_cce_vstai_u32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_s64 : ClangBuiltin<"__builtin_cce_vstai_s64">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  def int_hivm_vstai_bf16 : ClangBuiltin<"__builtin_cce_vstai_bf16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_f16 : ClangBuiltin<"__builtin_cce_vstai_f16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_f32 : ClangBuiltin<"__builtin_cce_vstai_f32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTAI Post mode
  def int_hivm_vstai_post_s8 : ClangBuiltin<"__builtin_cce_vstai_post_s8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_u8 : ClangBuiltin<"__builtin_cce_vstai_post_u8">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_s16 : ClangBuiltin<"__builtin_cce_vstai_post_s16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_u16 : ClangBuiltin<"__builtin_cce_vstai_post_u16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_s32 : ClangBuiltin<"__builtin_cce_vstai_post_s32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_u32 : ClangBuiltin<"__builtin_cce_vstai_post_u32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_s64 : ClangBuiltin<"__builtin_cce_vstai_post_s64">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  def int_hivm_vstai_post_bf16 : ClangBuiltin<"__builtin_cce_vstai_post_bf16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_f16 : ClangBuiltin<"__builtin_cce_vstai_post_f16">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstai_post_f32 : ClangBuiltin<"__builtin_cce_vstai_post_f32">,
    Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

// VSTAS Pre mode
def int_hivm_vstas_s8 : ClangBuiltin<"__builtin_cce_vstas_s8">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_u8 : ClangBuiltin<"__builtin_cce_vstas_u8">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_s16 : ClangBuiltin<"__builtin_cce_vstas_s16">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_u16 : ClangBuiltin<"__builtin_cce_vstas_u16">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
            [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_s32 : ClangBuiltin<"__builtin_cce_vstas_s32">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_u32 : ClangBuiltin<"__builtin_cce_vstas_u32">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_s64 : ClangBuiltin<"__builtin_cce_vstas_s64">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

def int_hivm_vstas_bf16 : ClangBuiltin<"__builtin_cce_vstas_bf16">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_f16 : ClangBuiltin<"__builtin_cce_vstas_f16">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_f32 : ClangBuiltin<"__builtin_cce_vstas_f32">,
  Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

// VSTAS Post mode
def int_hivm_vstas_post_s8 : ClangBuiltin<"__builtin_cce_vstas_post_s8">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_u8 : ClangBuiltin<"__builtin_cce_vstas_post_u8">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_s16 : ClangBuiltin<"__builtin_cce_vstas_post_s16">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_u16 : ClangBuiltin<"__builtin_cce_vstas_post_u16">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_s32 : ClangBuiltin<"__builtin_cce_vstas_post_s32">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_u32 : ClangBuiltin<"__builtin_cce_vstas_post_u32">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_s64 : ClangBuiltin<"__builtin_cce_vstas_post_s64">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

def int_hivm_vstas_post_bf16 : ClangBuiltin<"__builtin_cce_vstas_post_bf16">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_f16 : ClangBuiltin<"__builtin_cce_vstas_post_f16">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
def int_hivm_vstas_post_f32 : ClangBuiltin<"__builtin_cce_vstas_post_f32">,
  Intrinsic<[llvm_ptr_ty6], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
	        [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTUR
  def int_hivm_vstur_s8 : ClangBuiltin<"__builtin_cce_vstur_s8">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_u8 : ClangBuiltin<"__builtin_cce_vstur_u8">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_s16 : ClangBuiltin<"__builtin_cce_vstur_s16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_u16 : ClangBuiltin<"__builtin_cce_vstur_u16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_s32 : ClangBuiltin<"__builtin_cce_vstur_s32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_u32 : ClangBuiltin<"__builtin_cce_vstur_u32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_s64 : ClangBuiltin<"__builtin_cce_vstur_s64">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v32i64_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  def int_hivm_vstur_bf16 : ClangBuiltin<"__builtin_cce_vstur_bf16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_f16 : ClangBuiltin<"__builtin_cce_vstur_f16">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstur_f32 : ClangBuiltin<"__builtin_cce_vstur_f32">,
    Intrinsic<[llvm_v32i8_ty], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_v32i8_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSTAR
  def int_hivm_vstar_s8 : ClangBuiltin<"__builtin_cce_vstar_s8">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_u8 : ClangBuiltin<"__builtin_cce_vstar_u8">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_s16 : ClangBuiltin<"__builtin_cce_vstar_s16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_u16 : ClangBuiltin<"__builtin_cce_vstar_u16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_s32 : ClangBuiltin<"__builtin_cce_vstar_s32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_u32 : ClangBuiltin<"__builtin_cce_vstar_u32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_s64 : ClangBuiltin<"__builtin_cce_vstar_s64">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  def int_hivm_vstar_bf16 : ClangBuiltin<"__builtin_cce_vstar_bf16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_f16 : ClangBuiltin<"__builtin_cce_vstar_f16">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vstar_f32 : ClangBuiltin<"__builtin_cce_vstar_f32">,
    Intrinsic<[], [llvm_v32i8_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // SPRCLR
  def int_hivm_sprclr : ClangBuiltin<"__builtin_cce_sprclr">,
    Intrinsic<[], [llvm_i16_ty], [IntrNoMem, IntrHasSideEffects]>;

  // SPRSTI, Pre mode
  def int_hivm_sprsti : ClangBuiltin<"__builtin_cce_sprsti">,
    Intrinsic<[], [llvm_i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  // SPRSTI, Post mode
  def int_hivm_sprsti_post : ClangBuiltin<"__builtin_cce_sprsti_post">,
    Intrinsic<[llvm_ptr_ty6], [llvm_i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // SPRSTS, Pre mode
  def int_hivm_sprsts : ClangBuiltin<"__builtin_cce_sprsts">,
    Intrinsic<[], [llvm_i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  // SPRSTS, Post mode
  def int_hivm_sprsts_post : ClangBuiltin<"__builtin_cce_sprsts_post">,
    Intrinsic<[llvm_ptr_ty6], [llvm_i16_ty, llvm_ptr_ty6, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VSLD
  def int_hivm_vsld_v32s64 : ClangBuiltin<"__builtin_cce_vsld_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v64s32 : ClangBuiltin<"__builtin_cce_vsld_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v64u32 : ClangBuiltin<"__builtin_cce_vsld_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v128s16 : ClangBuiltin<"__builtin_cce_vsld_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v128u16 : ClangBuiltin<"__builtin_cce_vsld_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v256s8 : ClangBuiltin<"__builtin_cce_vsld_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v256u8 : ClangBuiltin<"__builtin_cce_vsld_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v64f32 : ClangBuiltin<"__builtin_cce_vsld_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v128f16 : ClangBuiltin<"__builtin_cce_vsld_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vsld_v128bf16 : ClangBuiltin<"__builtin_cce_vsld_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrArgMemOnly, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VSST
  def int_hivm_vsst_v64s32 : ClangBuiltin<"__builtin_cce_vsst_v64s32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v64u32 : ClangBuiltin<"__builtin_cce_vsst_v64u32">,
    Intrinsic<[], [llvm_v64i32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v128s16 : ClangBuiltin<"__builtin_cce_vsst_v128s16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v128u16 : ClangBuiltin<"__builtin_cce_vsst_v128u16">,
    Intrinsic<[], [llvm_v128i16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v256s8 : ClangBuiltin<"__builtin_cce_vsst_v256s8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v256u8 : ClangBuiltin<"__builtin_cce_vsst_v256u8">,
    Intrinsic<[], [llvm_v256i8_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v64f32 : ClangBuiltin<"__builtin_cce_vsst_v64f32">,
    Intrinsic<[], [llvm_v64f32_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v128f16 : ClangBuiltin<"__builtin_cce_vsst_v128f16">,
    Intrinsic<[], [llvm_v128f16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;
  def int_hivm_vsst_v128bf16 : ClangBuiltin<"__builtin_cce_vsst_v128bf16">,
    Intrinsic<[], [llvm_v128bf16_ty, llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrWriteMem, ReadOnly<ArgIndex<1>>, NoCapture<ArgIndex<1>>], "", [SDNPMemOperand]>;

  // VGATHERB
  def int_hivm_vgatherb_v32s64 : ClangBuiltin<"__builtin_cce_vgatherb_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v64s32 : ClangBuiltin<"__builtin_cce_vgatherb_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v64u32 : ClangBuiltin<"__builtin_cce_vgatherb_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v128s16 : ClangBuiltin<"__builtin_cce_vgatherb_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v128u16 : ClangBuiltin<"__builtin_cce_vgatherb_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v256s8 : ClangBuiltin<"__builtin_cce_vgatherb_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v256u8 : ClangBuiltin<"__builtin_cce_vgatherb_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v64f32 : ClangBuiltin<"__builtin_cce_vgatherb_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v128f16 : ClangBuiltin<"__builtin_cce_vgatherb_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;
  def int_hivm_vgatherb_v128bf16 : ClangBuiltin<"__builtin_cce_vgatherb_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_i32_ty, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>]>;

  // VGATHERB_V300
  def int_hivm_vgatherb_v300_v32s64 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v32s64">,
    Intrinsic<[llvm_v32i64_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v64s32 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v64u32 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v128s16 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v128u16 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v256s8 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v256s8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v256u8 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v256u8">,
    Intrinsic<[llvm_v256i8_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v64f32 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v128f16 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgatherb_v300_v128bf16 : ClangBuiltin<"__builtin_cce_vgatherb_v300_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_v64i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VGATHER2_V300
  def int_hivm_vgather2_v300_v64s32 : ClangBuiltin<"__builtin_cce_vgather2_v300_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v64u32 : ClangBuiltin<"__builtin_cce_vgather2_v300_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v128s16 : ClangBuiltin<"__builtin_cce_vgather2_v300_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v128u16 : ClangBuiltin<"__builtin_cce_vgather2_v300_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v256s8 : ClangBuiltin<"__builtin_cce_vgather2_v300_v256s8">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v256u8 : ClangBuiltin<"__builtin_cce_vgather2_v300_v256u8">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v64f32 : ClangBuiltin<"__builtin_cce_vgather2_v300_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v128f16 : ClangBuiltin<"__builtin_cce_vgather2_v300_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_v300_v128bf16 : ClangBuiltin<"__builtin_cce_vgather2_v300_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VGATHER2
  def int_hivm_vgather2_v64s32 : ClangBuiltin<"__builtin_cce_vgather2_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v64u32 : ClangBuiltin<"__builtin_cce_vgather2_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v128s16 : ClangBuiltin<"__builtin_cce_vgather2_v128s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v128u16 : ClangBuiltin<"__builtin_cce_vgather2_v128u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v256s8 : ClangBuiltin<"__builtin_cce_vgather2_v256s8">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v256u8 : ClangBuiltin<"__builtin_cce_vgather2_v256u8">,
    Intrinsic<[llvm_v128i16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v64f32 : ClangBuiltin<"__builtin_cce_vgather2_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v128f16 : ClangBuiltin<"__builtin_cce_vgather2_v128f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;
  def int_hivm_vgather2_v128bf16 : ClangBuiltin<"__builtin_cce_vgather2_v128bf16">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_ptr_ty6, llvm_v1i32_ty, llvm_ptr_ty6, llvm_i32_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>, ReadOnly<ArgIndex<2>>, NoCapture<ArgIndex<2>>]>;

  // VGATHER2_BC
  // If type=b16, each gathered element occupied 32bit with upper 16bit zero.
  def int_hivm_vgather2_bc_v64s32 : ClangBuiltin<"__builtin_cce_vgather2_bc_v64s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_bc_v64u32 : ClangBuiltin<"__builtin_cce_vgather2_bc_v64u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_bc_v128s16 : ClangBuiltin<"__builtin_cce_vgather2_bc_v128s16">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_bc_v128u16 : ClangBuiltin<"__builtin_cce_vgather2_bc_v128u16">,
    Intrinsic<[llvm_v64i32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_bc_v64f32 : ClangBuiltin<"__builtin_cce_vgather2_bc_v64f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;
  def int_hivm_vgather2_bc_v128f16 : ClangBuiltin<"__builtin_cce_vgather2_bc_v128f16">,
    Intrinsic<[llvm_v64f32_ty], [llvm_ptr_ty6, llvm_v64i32_ty, llvm_v256i1_ty],
              [IntrReadMem, ReadOnly<ArgIndex<0>>, NoCapture<ArgIndex<0>>], "", [SDNPMemOperand]>;

  // VFCVT
  def int_hivm_vfcvt_f162s16_m : ClangBuiltin<"__builtin_cce_vfcvt_f162s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_s162f16_m : ClangBuiltin<"__builtin_cce_vfcvt_s162f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_s322f32_m : ClangBuiltin<"__builtin_cce_vfcvt_s322f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f322s32_m : ClangBuiltin<"__builtin_cce_vfcvt_f322s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64f32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vfcvt_f162s16_x : ClangBuiltin<"__builtin_cce_vfcvt_f162s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_s162f16_x : ClangBuiltin<"__builtin_cce_vfcvt_s162f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_s322f32_x : ClangBuiltin<"__builtin_cce_vfcvt_s322f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f322s32_x : ClangBuiltin<"__builtin_cce_vfcvt_f322s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64f32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vfcvt_f322f16_m : ClangBuiltin<"__builtin_cce_vfcvt_f322f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v64f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f322s16_m : ClangBuiltin<"__builtin_cce_vfcvt_f322s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f162s8_m : ClangBuiltin<"__builtin_cce_vfcvt_f162s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f162u8_m : ClangBuiltin<"__builtin_cce_vfcvt_f162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vfcvt_f322f16_x : ClangBuiltin<"__builtin_cce_vfcvt_f322f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v64f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f322s16_x : ClangBuiltin<"__builtin_cce_vfcvt_f322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f162s8_x : ClangBuiltin<"__builtin_cce_vfcvt_f162s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f162u8_x : ClangBuiltin<"__builtin_cce_vfcvt_f162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vfcvt_f162s32 : ClangBuiltin<"__builtin_cce_vfcvt_f162s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_f162f32 : ClangBuiltin<"__builtin_cce_vfcvt_f162f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v128f16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_s162f32 : ClangBuiltin<"__builtin_cce_vfcvt_s162f32">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_u82f16 : ClangBuiltin<"__builtin_cce_vfcvt_u82f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vfcvt_s82f16 : ClangBuiltin<"__builtin_cce_vfcvt_s82f16">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;

  // VSFCVT
  def int_hivm_vsfcvt_f322s32_m : ClangBuiltin<"__builtin_cce_vsfcvt_f322s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64f32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsfcvt_f162s16_m : ClangBuiltin<"__builtin_cce_vsfcvt_f162s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vsfcvt_f322s32_x : ClangBuiltin<"__builtin_cce_vsfcvt_f322s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64f32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vsfcvt_f162s16_x : ClangBuiltin<"__builtin_cce_vsfcvt_f162s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vsfcvt_f322s16_m : ClangBuiltin<"__builtin_cce_vsfcvt_f322s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vsfcvt_f162s8_m : ClangBuiltin<"__builtin_cce_vsfcvt_f162s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vsfcvt_f162u8_m : ClangBuiltin<"__builtin_cce_vsfcvt_f162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vsfcvt_f322s16_x : ClangBuiltin<"__builtin_cce_vsfcvt_f322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64f32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vsfcvt_f162s8_x : ClangBuiltin<"__builtin_cce_vsfcvt_f162s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vsfcvt_f162u8_x : ClangBuiltin<"__builtin_cce_vsfcvt_f162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VCVT
  def int_hivm_vcvt_u162u8_m : ClangBuiltin<"__builtin_cce_vcvt_u162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s162u8_m : ClangBuiltin<"__builtin_cce_vcvt_s162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_u322u16_m : ClangBuiltin<"__builtin_cce_vcvt_u322u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_u322s16_m : ClangBuiltin<"__builtin_cce_vcvt_u322s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s322u16_m : ClangBuiltin<"__builtin_cce_vcvt_s322u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s322s16_m : ClangBuiltin<"__builtin_cce_vcvt_s322s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvt_u162u8_x : ClangBuiltin<"__builtin_cce_vcvt_u162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s162u8_x : ClangBuiltin<"__builtin_cce_vcvt_s162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_u322u16_x : ClangBuiltin<"__builtin_cce_vcvt_u322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_u322s16_x : ClangBuiltin<"__builtin_cce_vcvt_u322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s322u16_x : ClangBuiltin<"__builtin_cce_vcvt_s322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s322s16_x : ClangBuiltin<"__builtin_cce_vcvt_s322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvt_u82u16 : ClangBuiltin<"__builtin_cce_vcvt_u82u16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s82s16 : ClangBuiltin<"__builtin_cce_vcvt_s82s16">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_u162u32 : ClangBuiltin<"__builtin_cce_vcvt_u162u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s162u32 : ClangBuiltin<"__builtin_cce_vcvt_s162u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s162s32 : ClangBuiltin<"__builtin_cce_vcvt_s162s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;

  // #pp
  def int_hivm_vcvt_u82u32 : ClangBuiltin<"__builtin_cce_vcvt_u82u32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s82s32 : ClangBuiltin<"__builtin_cce_vcvt_s82s32">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v256i8_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvt_u322u8_m : ClangBuiltin<"__builtin_cce_vcvt_u322u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_u322u8_x  : ClangBuiltin<"__builtin_cce_vcvt_u322u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvt_s322u8_m : ClangBuiltin<"__builtin_cce_vcvt_s322u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvt_s322u8_x : ClangBuiltin<"__builtin_cce_vcvt_s322u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VSCVT
  def int_hivm_vscvt_u162u8_m : ClangBuiltin<"__builtin_cce_vscvt_u162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s162u8_m : ClangBuiltin<"__builtin_cce_vscvt_s162u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_u322u16_m : ClangBuiltin<"__builtin_cce_vscvt_u322u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_u322s16_m : ClangBuiltin<"__builtin_cce_vscvt_u322s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s322u16_m : ClangBuiltin<"__builtin_cce_vscvt_s322u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s322s16_m : ClangBuiltin<"__builtin_cce_vscvt_s322s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vscvt_u162u8_x : ClangBuiltin<"__builtin_cce_vscvt_u162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s162u8_x : ClangBuiltin<"__builtin_cce_vscvt_s162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_u322u16_x : ClangBuiltin<"__builtin_cce_vscvt_u322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_u322s16_x : ClangBuiltin<"__builtin_cce_vscvt_u322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s322u16_x : ClangBuiltin<"__builtin_cce_vscvt_s322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s322s16_x : ClangBuiltin<"__builtin_cce_vscvt_s322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vscvt_u322u8_m : ClangBuiltin<"__builtin_cce_vscvt_u322u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s322u8_m : ClangBuiltin<"__builtin_cce_vscvt_s322u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vscvt_u322u8_x : ClangBuiltin<"__builtin_cce_vscvt_u322u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vscvt_s322u8_x : ClangBuiltin<"__builtin_cce_vscvt_s322u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v64i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VCVTFI
  def int_hivm_vcvtfi_f322s16_x : ClangBuiltin<"__builtin_cce_vcvtfi_f322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtfi_f162u8_x : ClangBuiltin<"__builtin_cce_vcvtfi_f162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtfi_f162s8_x : ClangBuiltin<"__builtin_cce_vcvtfi_f162s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtfi_f322s64_x : ClangBuiltin<"__builtin_cce_vcvtfi_f322s64_x">,
    Intrinsic<[llvm_v32i64_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtfi_bf162s32_x : ClangBuiltin<"__builtin_cce_vcvtfi_bf162s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128bf16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtfi_f322s32_x : ClangBuiltin<"__builtin_cce_vcvtfi_f322s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtfi_f162s16_x : ClangBuiltin<"__builtin_cce_vcvtfi_f162s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtfi_f162s32_x : ClangBuiltin<"__builtin_cce_vcvtfi_f162s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtfi_f162s4x2_x : ClangBuiltin<"__builtin_cce_vcvtfi_f162s4x2_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VCVTFF
  def int_hivm_vcvtff_f322f16_x : ClangBuiltin<"__builtin_cce_vcvtff_f322f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtff_f322bf16_x : ClangBuiltin<"__builtin_cce_vcvtff_f322bf16_x">,
    Intrinsic<[llvm_v128bf16_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtff_f162f32_x : ClangBuiltin<"__builtin_cce_vcvtff_f162f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtff_bf162f32_x : ClangBuiltin<"__builtin_cce_vcvtff_bf162f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v128bf16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // VCVTIF
  def int_hivm_vcvtif_u82f16_x : ClangBuiltin<"__builtin_cce_vcvtif_u82f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtif_s82f16_x : ClangBuiltin<"__builtin_cce_vcvtif_s82f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtif_s162f32_x : ClangBuiltin<"__builtin_cce_vcvtif_s162f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtif_s162f16_x : ClangBuiltin<"__builtin_cce_vcvtif_s162f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtif_s322f32_x : ClangBuiltin<"__builtin_cce_vcvtif_s322f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtif_s642f32_x : ClangBuiltin<"__builtin_cce_vcvtif_s642f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v32i64_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtif_s4x22f16_x : ClangBuiltin<"__builtin_cce_vcvtif_s4x22f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  // VCVTII
  def int_hivm_vcvtii_u82u16_x : ClangBuiltin<"__builtin_cce_vcvtii_u82u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s82s16_x : ClangBuiltin<"__builtin_cce_vcvtii_s82s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_u162u32_x : ClangBuiltin<"__builtin_cce_vcvtii_u162u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s162u32_x : ClangBuiltin<"__builtin_cce_vcvtii_s162u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s162s32_x : ClangBuiltin<"__builtin_cce_vcvtii_s162s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s322s64_x : ClangBuiltin<"__builtin_cce_vcvtii_s322s64_x">,
    Intrinsic<[llvm_v32i64_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtii_u162u8_x : ClangBuiltin<"__builtin_cce_vcvtii_u162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s162u8_x : ClangBuiltin<"__builtin_cce_vcvtii_s162u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_u322u16_x : ClangBuiltin<"__builtin_cce_vcvtii_u322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_u322s16_x : ClangBuiltin<"__builtin_cce_vcvtii_u322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s322u16_x : ClangBuiltin<"__builtin_cce_vcvtii_s322u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s322s16_x : ClangBuiltin<"__builtin_cce_vcvtii_s322s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s642s32_x : ClangBuiltin<"__builtin_cce_vcvtii_s642s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v32i64_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtii_u82u32_x : ClangBuiltin<"__builtin_cce_vcvtii_u82u32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s82s32_x : ClangBuiltin<"__builtin_cce_vcvtii_s82s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtii_u322u8_x : ClangBuiltin<"__builtin_cce_vcvtii_u322u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s322u8_x : ClangBuiltin<"__builtin_cce_vcvtii_s322u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  def int_hivm_vcvtii_s4x22s16_x : ClangBuiltin<"__builtin_cce_vcvtii_s4x22s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty], [IntrNoMem]>;
  def int_hivm_vcvtii_s162s4x2_x : ClangBuiltin<"__builtin_cce_vcvtii_s162s4x2_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem]>;

  // VTRC
  def int_hivm_vtrc_f16_m : ClangBuiltin<"__builtin_cce_vtrc_f16_m">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vtrc_f32_m : ClangBuiltin<"__builtin_cce_vtrc_f32_m">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vtrc_f16_x : ClangBuiltin<"__builtin_cce_vtrc_f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vtrc_f32_x : ClangBuiltin<"__builtin_cce_vtrc_f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCMP
  def int_hivm_vcmp_eq_u8_z : ClangBuiltin<"__builtin_cce_vcmp_eq_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_u8_z : ClangBuiltin<"__builtin_cce_vcmp_ne_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_u8_z : ClangBuiltin<"__builtin_cce_vcmp_gt_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_u8_z : ClangBuiltin<"__builtin_cce_vcmp_ge_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_u8_z : ClangBuiltin<"__builtin_cce_vcmp_lt_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_u8_z : ClangBuiltin<"__builtin_cce_vcmp_le_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_s8_z : ClangBuiltin<"__builtin_cce_vcmp_eq_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_s8_z : ClangBuiltin<"__builtin_cce_vcmp_ne_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_s8_z : ClangBuiltin<"__builtin_cce_vcmp_gt_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_s8_z : ClangBuiltin<"__builtin_cce_vcmp_ge_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_s8_z : ClangBuiltin<"__builtin_cce_vcmp_lt_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_s8_z : ClangBuiltin<"__builtin_cce_vcmp_le_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_u16_z : ClangBuiltin<"__builtin_cce_vcmp_eq_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_u16_z : ClangBuiltin<"__builtin_cce_vcmp_ne_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_u16_z : ClangBuiltin<"__builtin_cce_vcmp_gt_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_u16_z : ClangBuiltin<"__builtin_cce_vcmp_ge_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_u16_z : ClangBuiltin<"__builtin_cce_vcmp_lt_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_u16_z : ClangBuiltin<"__builtin_cce_vcmp_le_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_s16_z : ClangBuiltin<"__builtin_cce_vcmp_eq_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_s16_z : ClangBuiltin<"__builtin_cce_vcmp_ne_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_s16_z : ClangBuiltin<"__builtin_cce_vcmp_gt_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_s16_z : ClangBuiltin<"__builtin_cce_vcmp_ge_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_s16_z : ClangBuiltin<"__builtin_cce_vcmp_lt_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_s16_z : ClangBuiltin<"__builtin_cce_vcmp_le_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_u32_z : ClangBuiltin<"__builtin_cce_vcmp_eq_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_u32_z : ClangBuiltin<"__builtin_cce_vcmp_ne_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_u32_z : ClangBuiltin<"__builtin_cce_vcmp_gt_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_u32_z : ClangBuiltin<"__builtin_cce_vcmp_ge_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_u32_z : ClangBuiltin<"__builtin_cce_vcmp_lt_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_u32_z : ClangBuiltin<"__builtin_cce_vcmp_le_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_s32_z : ClangBuiltin<"__builtin_cce_vcmp_eq_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_s32_z : ClangBuiltin<"__builtin_cce_vcmp_ne_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_s32_z : ClangBuiltin<"__builtin_cce_vcmp_gt_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_s32_z : ClangBuiltin<"__builtin_cce_vcmp_ge_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_s32_z : ClangBuiltin<"__builtin_cce_vcmp_lt_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_s32_z : ClangBuiltin<"__builtin_cce_vcmp_le_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_f16_z : ClangBuiltin<"__builtin_cce_vcmp_eq_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_f16_z : ClangBuiltin<"__builtin_cce_vcmp_ne_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_f16_z : ClangBuiltin<"__builtin_cce_vcmp_gt_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_f16_z : ClangBuiltin<"__builtin_cce_vcmp_ge_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_f16_z : ClangBuiltin<"__builtin_cce_vcmp_lt_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_f16_z : ClangBuiltin<"__builtin_cce_vcmp_le_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmp_eq_f32_z : ClangBuiltin<"__builtin_cce_vcmp_eq_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ne_f32_z : ClangBuiltin<"__builtin_cce_vcmp_ne_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_gt_f32_z : ClangBuiltin<"__builtin_cce_vcmp_gt_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_ge_f32_z : ClangBuiltin<"__builtin_cce_vcmp_ge_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_lt_f32_z : ClangBuiltin<"__builtin_cce_vcmp_lt_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmp_le_f32_z : ClangBuiltin<"__builtin_cce_vcmp_le_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCMPS
  def int_hivm_vcmps_eq_u8_z : ClangBuiltin<"__builtin_cce_vcmps_eq_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_u8_z : ClangBuiltin<"__builtin_cce_vcmps_ne_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_u8_z : ClangBuiltin<"__builtin_cce_vcmps_gt_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_u8_z : ClangBuiltin<"__builtin_cce_vcmps_ge_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_u8_z : ClangBuiltin<"__builtin_cce_vcmps_lt_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_u8_z : ClangBuiltin<"__builtin_cce_vcmps_le_u8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_s8_z : ClangBuiltin<"__builtin_cce_vcmps_eq_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_s8_z : ClangBuiltin<"__builtin_cce_vcmps_ne_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_s8_z : ClangBuiltin<"__builtin_cce_vcmps_gt_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_s8_z : ClangBuiltin<"__builtin_cce_vcmps_ge_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_s8_z : ClangBuiltin<"__builtin_cce_vcmps_lt_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_s8_z : ClangBuiltin<"__builtin_cce_vcmps_le_s8_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v256i8_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_u16_z : ClangBuiltin<"__builtin_cce_vcmps_eq_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_u16_z : ClangBuiltin<"__builtin_cce_vcmps_ne_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_u16_z : ClangBuiltin<"__builtin_cce_vcmps_gt_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_u16_z : ClangBuiltin<"__builtin_cce_vcmps_ge_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_u16_z : ClangBuiltin<"__builtin_cce_vcmps_lt_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_u16_z : ClangBuiltin<"__builtin_cce_vcmps_le_u16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_s16_z : ClangBuiltin<"__builtin_cce_vcmps_eq_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_s16_z : ClangBuiltin<"__builtin_cce_vcmps_ne_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_s16_z : ClangBuiltin<"__builtin_cce_vcmps_gt_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_s16_z : ClangBuiltin<"__builtin_cce_vcmps_ge_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_s16_z : ClangBuiltin<"__builtin_cce_vcmps_lt_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_s16_z : ClangBuiltin<"__builtin_cce_vcmps_le_s16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_u32_z : ClangBuiltin<"__builtin_cce_vcmps_eq_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_u32_z : ClangBuiltin<"__builtin_cce_vcmps_ne_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_u32_z : ClangBuiltin<"__builtin_cce_vcmps_gt_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_u32_z : ClangBuiltin<"__builtin_cce_vcmps_ge_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_u32_z : ClangBuiltin<"__builtin_cce_vcmps_lt_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_u32_z : ClangBuiltin<"__builtin_cce_vcmps_le_u32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_s32_z : ClangBuiltin<"__builtin_cce_vcmps_eq_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_s32_z : ClangBuiltin<"__builtin_cce_vcmps_ne_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_s32_z : ClangBuiltin<"__builtin_cce_vcmps_gt_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_s32_z : ClangBuiltin<"__builtin_cce_vcmps_ge_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_s32_z : ClangBuiltin<"__builtin_cce_vcmps_lt_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_s32_z : ClangBuiltin<"__builtin_cce_vcmps_le_s32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64i32_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_f16_z : ClangBuiltin<"__builtin_cce_vcmps_eq_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_f16_z : ClangBuiltin<"__builtin_cce_vcmps_ne_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_f16_z : ClangBuiltin<"__builtin_cce_vcmps_gt_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_f16_z : ClangBuiltin<"__builtin_cce_vcmps_ge_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_f16_z : ClangBuiltin<"__builtin_cce_vcmps_lt_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_f16_z : ClangBuiltin<"__builtin_cce_vcmps_le_f16_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v128f16_ty, llvm_half_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcmps_eq_f32_z : ClangBuiltin<"__builtin_cce_vcmps_eq_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ne_f32_z : ClangBuiltin<"__builtin_cce_vcmps_ne_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_gt_f32_z : ClangBuiltin<"__builtin_cce_vcmps_gt_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_ge_f32_z : ClangBuiltin<"__builtin_cce_vcmps_ge_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_lt_f32_z : ClangBuiltin<"__builtin_cce_vcmps_lt_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcmps_le_f32_z : ClangBuiltin<"__builtin_cce_vcmps_le_f32_z">,
    Intrinsic<[llvm_v256i1_ty], [llvm_v64f32_ty, llvm_float_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // Currently, we use IntrHasSideEffects for vbr, if not it may be optimized to VMOV which is an EX stage instrinsic
  def int_hivm_vbr_s8 : ClangBuiltin<"vbr_s8">,
      Intrinsic<[llvm_v256i8_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_u8 : ClangBuiltin<"vbr_u8">,
      Intrinsic<[llvm_v256i8_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_s16 : ClangBuiltin<"vbr_s16">,
      Intrinsic<[llvm_v128i16_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_u16 : ClangBuiltin<"vbr_u16">,
      Intrinsic<[llvm_v128i16_ty], [llvm_i16_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_s32 : ClangBuiltin<"vbr_s32">,
      Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_u32 : ClangBuiltin<"vbr_u32">,
      Intrinsic<[llvm_v64i32_ty], [llvm_i32_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_f16 : ClangBuiltin<"vbr_f16">,
      Intrinsic<[llvm_v128f16_ty], [llvm_half_ty, llvm_i32_ty], [IntrHasSideEffects]>;
  def int_hivm_vbr_f32 : ClangBuiltin<"vbr_f32">,
      Intrinsic<[llvm_v64f32_ty], [llvm_float_ty, llvm_i32_ty], [IntrHasSideEffects]>;

  // VAVG
  def int_hivm_vavg_v128s16_m : ClangBuiltin<"__builtin_cce_vavg_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vavg_v128u16_m : ClangBuiltin<"__builtin_cce_vavg_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vavg_v256s8_m : ClangBuiltin<"__builtin_cce_vavg_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vavg_v256u8_m : ClangBuiltin<"__builtin_cce_vavg_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vavg_v128s16_x : ClangBuiltin<"__builtin_cce_vavg_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vavg_v128u16_x : ClangBuiltin<"__builtin_cce_vavg_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vavg_v256s8_x : ClangBuiltin<"__builtin_cce_vavg_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vavg_v256u8_x : ClangBuiltin<"__builtin_cce_vavg_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty], [llvm_v256i8_ty, llvm_v256i8_ty, llvm_i32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCBMAX
  def int_hivm_vcbmax_v128s16_m : ClangBuiltin<"__builtin_cce_vcbmax_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v128u16_m : ClangBuiltin<"__builtin_cce_vcbmax_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v256s8_m : ClangBuiltin<"__builtin_cce_vcbmax_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v256u8_m : ClangBuiltin<"__builtin_cce_vcbmax_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v64s32_m : ClangBuiltin<"__builtin_cce_vcbmax_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v64u32_m : ClangBuiltin<"__builtin_cce_vcbmax_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v128f16_m : ClangBuiltin<"__builtin_cce_vcbmax_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty, llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v64f32_m : ClangBuiltin<"__builtin_cce_vcbmax_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty, llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcbmax_v128s16_x : ClangBuiltin<"__builtin_cce_vcbmax_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v128u16_x : ClangBuiltin<"__builtin_cce_vcbmax_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v256s8_x : ClangBuiltin<"__builtin_cce_vcbmax_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v256u8_x : ClangBuiltin<"__builtin_cce_vcbmax_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v64s32_x : ClangBuiltin<"__builtin_cce_vcbmax_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v64u32_x : ClangBuiltin<"__builtin_cce_vcbmax_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v128f16_x : ClangBuiltin<"__builtin_cce_vcbmax_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty, llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmax_v64f32_x : ClangBuiltin<"__builtin_cce_vcbmax_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty, llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCBMIN
  def int_hivm_vcbmin_v128s16_m : ClangBuiltin<"__builtin_cce_vcbmin_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v128u16_m : ClangBuiltin<"__builtin_cce_vcbmin_v128u16_m">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty, llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v256s8_m : ClangBuiltin<"__builtin_cce_vcbmin_v256s8_m">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v256u8_m : ClangBuiltin<"__builtin_cce_vcbmin_v256u8_m">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty, llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v64s32_m : ClangBuiltin<"__builtin_cce_vcbmin_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v64u32_m : ClangBuiltin<"__builtin_cce_vcbmin_v64u32_m">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty, llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v128f16_m : ClangBuiltin<"__builtin_cce_vcbmin_v128f16_m">,
    Intrinsic<[llvm_v128f16_ty, llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v256i1_ty, llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v64f32_m : ClangBuiltin<"__builtin_cce_vcbmin_v64f32_m">,
    Intrinsic<[llvm_v64f32_ty, llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v256i1_ty, llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vcbmin_v128s16_x : ClangBuiltin<"__builtin_cce_vcbmin_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v128u16_x : ClangBuiltin<"__builtin_cce_vcbmin_v128u16_x">,
    Intrinsic<[llvm_v128i16_ty, llvm_v256i1_ty], [llvm_v128i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v256s8_x : ClangBuiltin<"__builtin_cce_vcbmin_v256s8_x">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v256u8_x : ClangBuiltin<"__builtin_cce_vcbmin_v256u8_x">,
    Intrinsic<[llvm_v256i8_ty, llvm_v256i1_ty], [llvm_v256i8_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v64s32_x : ClangBuiltin<"__builtin_cce_vcbmin_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v64u32_x : ClangBuiltin<"__builtin_cce_vcbmin_v64u32_x">,
    Intrinsic<[llvm_v64i32_ty, llvm_v256i1_ty], [llvm_v64i32_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v128f16_x : ClangBuiltin<"__builtin_cce_vcbmin_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty, llvm_v256i1_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcbmin_v64f32_x : ClangBuiltin<"__builtin_cce_vcbmin_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty, llvm_v256i1_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCGADD
  def int_hivm_vcgadd_v128f16_x : ClangBuiltin<"__builtin_cce_vcgadd_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcgadd_v64f32_x : ClangBuiltin<"__builtin_cce_vcgadd_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCGMAX
  def int_hivm_vcgmax_v128f16_x : ClangBuiltin<"__builtin_cce_vcgmax_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcgmax_v64f32_x : ClangBuiltin<"__builtin_cce_vcgmax_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCGMIN
  def int_hivm_vcgmin_v128f16_x : ClangBuiltin<"__builtin_cce_vcgmin_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcgmin_v64f32_x : ClangBuiltin<"__builtin_cce_vcgmin_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VCPADD
  def int_hivm_vcpadd_v128f16_x : ClangBuiltin<"__builtin_cce_vcpadd_v128f16_x">,
    Intrinsic<[llvm_v128f16_ty], [llvm_v128f16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vcpadd_v64f32_x : ClangBuiltin<"__builtin_cce_vcpadd_v64f32_x">,
    Intrinsic<[llvm_v64f32_ty], [llvm_v64f32_ty, llvm_v256i1_ty], [IntrNoMem]>;

  // VL = 2048 bit
  // VRNDS
  def int_hivm_vrnds_v64s32_m : ClangBuiltin<"__builtin_cce_vrnds_v64s32_m">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrnds_v128s16_m : ClangBuiltin<"__builtin_cce_vrnds_v128s16_m">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_vrnds_v64s32_x : ClangBuiltin<"__builtin_cce_vrnds_v64s32_x">,
    Intrinsic<[llvm_v64i32_ty], [llvm_v64i32_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;
  def int_hivm_vrnds_v128s16_x : ClangBuiltin<"__builtin_cce_vrnds_v128s16_x">,
    Intrinsic<[llvm_v128i16_ty], [llvm_v128i16_ty, llvm_i16_ty, llvm_v256i1_ty], [IntrNoMem]>;

  def int_hivm_init_vector_align_data : ClangBuiltin<"__builtin_cce_init_vector_align_data">,
    Intrinsic<[llvm_v32i8_ty], [], []>;

  def int_hivm_bf_cvt_h : Intrinsic<[llvm_half_ty], [llvm_bfloat_ty], [IntrNoMem]>;
  def int_hivm_h_cvt_bf : Intrinsic<[llvm_bfloat_ty], [llvm_half_ty], [IntrNoMem]>;

  def int_hivm_mulhu : Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty], [IntrNoMem, Commutative]>;

  // SET_FLAG and WAIT_FLAG.
  // Define just for pushq encoding, used in HiIPUExpandPseudoInsts.cpp.
  def int_hivm_set_flag_imm_v210:  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_set_flag_reg_v210:  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_wait_flag_imm_v210: Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_wait_flag_reg_v210: Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_set_flag_imm_v300:  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_set_flag_reg_v300:  Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_wait_flag_imm_v300: Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_wait_flag_reg_v300: Intrinsic<[], [llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;

  def int_hivm_trap_mov : ClangBuiltin<"__builtin_cce_trap_mov">,
    Intrinsic<[], [llvm_i64_ty], [IntrHasSideEffects]>;

  def int_hivm_block_local_data_init: Intrinsic<[], [llvm_i64_ty, llvm_i64_ty],[IntrHasSideEffects]>;
  def int_hivm_get_func_label_addr: Intrinsic<[llvm_i64_ty], [],[IntrNoMem]>;
  def int_hivm_get_stack_base: Intrinsic<[llvm_i64_ty], [],[IntrNoMem]>;
  //===----------------------------------------------------------------------===//
  // V100 TRAP For Debug
  //===----------------------------------------------------------------------===//
  def int_hivm_debug_printf : ClangBuiltin<"debug_printf">,
    Intrinsic<[], [llvm_ptr_ty1, llvm_vararg_ty], [IntrHasSideEffects]>;
  def int_hivm_debug_assert_fail : ClangBuiltin<"__builtin_cce_debug_assert_fail">,
    Intrinsic<[], [llvm_ptr_ty1, llvm_ptr_ty1, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_debug_read : ClangBuiltin<"debug_read">,
    Intrinsic<[llvm_i64_ty], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
  def int_hivm_debug_dump : ClangBuiltin<"__builtin_cce_debug_dump">,
    Intrinsic<[], [llvm_ptr_ty1, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;

#ifdef HIIPU_AABASED_AUTOSYNC
  def int_hivm_SET_FLAG_IMM_VIRTUAL:
    Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;

  def int_hivm_WAIT_FLAG_IMM_VIRTUAL:
    Intrinsic<[], [llvm_i64_ty, llvm_i64_ty, llvm_i64_ty], [IntrHasSideEffects]>;
#endif
} // End of 'let TargetPrefix = "hivm"'
#endif
