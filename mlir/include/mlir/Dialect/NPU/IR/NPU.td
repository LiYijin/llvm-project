//===- NPU.td - NPU dialect ------------------------------------*- tablegen -*-===//
//
// This file declares the NPU dialect.
//
//===----------------------------------------------------------------------===//

#ifndef NPU_DIALECT
#define NPU_DIALECT

include "mlir/IR/OpBase.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Dialect/LLVMIR/LLVMOpBase.td"

def NPU_Dialect : Dialect {
  let name = "npu";
  let description = [{}];
  let cppNamespace = "::mlir::npu";
}



class NPU_Op<string mnemonic, list<Trait> traits = []> 
  : Op<NPU_Dialect, mnemonic, traits>;

def VAddF32Op : NPU_Op<"vadd", [Pure]> {
  let summary = "Vector add operation";
  let description = [{
    The `vadd` operation adds two vectors element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

def VSubF32Op : NPU_Op<"vsub_f32", [Pure]> {
  let summary = "Vector float32 sub operation";
  let description = [{
    The `vsub_f32` operation subs two vectors element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

def VMulF32Op : NPU_Op<"vmul_f32", [Pure]> {
  let summary = "Vector float32 mul operation";
  let description = [{
    The `vmul_f32` operation muls two vectors element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

def VDivF32Op : NPU_Op<"vdiv_f32", [Pure]> {
  let summary = "Vector float32 div operation";
  let description = [{
    The `vdiv_f32` operation divs two vectors element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];

  let hasCanonicalizeMethod = 1;
}

def VExpF32Op : NPU_Op<"vexp_f32", [Pure]> {
  let summary = "Vector float32 exp operation";
  let description = [{
    The `vexp_f32` operation compute exp value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$operand, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$operand, "IntegerAttr":$numElems)>
  ];
}

def VRsqrtF32Op : NPU_Op<"vrsqrt_f32", [Pure]> {
  let summary = "Vector float32 rsqrt operation";
  let description = [{
    The `vrsqrt_f32` operation compute rsqrt value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$operand, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$operand, "IntegerAttr":$numElems)>
  ];
}

def VSqrtF32Op : NPU_Op<"vsqrt_f32", [Pure]> {
  let summary = "Vector float32 sqrt operation";
  let description = [{
    The `vsqrt_f32` operation compute sqrt value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$operand, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$operand, "IntegerAttr":$numElems)>
  ];
}

def SSQRTF32Op : NPU_Op<"ssqrt_f32", [Pure]> {
  let summary = "Scalar float32 sqrt operation";
  let description = [{
    The `ssqrt_f32` operation compute sqrt value of input scalar.
  }];

  let arguments = (ins F32:$operand);
  let results = (outs F32:$res);

  let builders = [
    OpBuilder<(ins "Value":$operand)>
  ];
}

def VMaxF32Op : NPU_Op<"vmax_f32", [Pure]> {
  let summary = "Vector float32 max operation";
  let description = [{
    The `vmax_f32` operation compute max value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

// Note: Now VAddSF32Op and VMulSF32Op are not used in the codebase, 
// waiting for further optimization.
def VAddSF32Op : NPU_Op<"vadds_f32", [Pure]> {
  let summary = "Vector float32 add scalar operation";
  let description = [{
    The `vadds_f32` operation adds a scalar to a vector element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, F32:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

def VMulSF32Op : NPU_Op<"vmuls_f32", [Pure]> {
  let summary = "Vector float32 mul scalar operation";
  let description = [{
    The `vmuls_f32` operation muls a scalar to a vector element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, F32:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

def VTanhF32Op : NPU_Op<"vtanh_f32", [Pure]> {
  let summary = "Vector float32 tanh operation";
  let description = [{
    The `vtanh_f32` operation compute tanh value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$operand, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$operand, "IntegerAttr":$numElems)>
  ];
}

def VSigmoidF32Op : NPU_Op<"vsigmoid_f32", [Pure]> {
  let summary = "Vector float32 sigmoid operation";
  let description = [{
    The `vsigmoid_f32` operation compute sigmoid value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$operand, I32Attr:$numElems);
  let results = (outs AnyVector:$res);
}

def VRecipF32Op : NPU_Op<"vrecip_f32", [Pure]> {
  let summary = "Vector float32 recip operation";
  let description = [{
    The `vrecip_f32` operation compute reciprocal value of input vector element-wise.
  }];

  let arguments = (ins AnyVector:$operand, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$operand, "IntegerAttr":$numElems)>
  ];  
}

def NPU_BlockIdOp : NPU_Op<"block_id", [Pure]> {
  let summary = "Get block id";
  let description = [{
    The `npu.block_id` operation returns the block id.
  }];

  let arguments = (ins
    StrAttr:$dimension);

  let results = (outs I64:$res);
}

def NPU_BlockNumOp : NPU_Op<"block_num", [Pure]> {
  let summary = "Get block num";
  let description = [{
    The `npu.block_num` operation returns the block num.
  }];

  let arguments = (ins
    StrAttr:$dimension);

  let results = (outs I64:$res);
}

def AtomicAddF32Op : NPU_Op<"atomic_add_f32", [MemoryEffects<[MemWrite, MemWrite]>]> {
  let summary = "Atomic add f32 operation";
  // NOTE: Is scalar atomic_add_f32 possible? Or only vector type?
  let description = [{
    The `atomic_add_f32` operation atomically adds a float32 vector to a 
    float32 vector in memory.
  }];
  let arguments = (ins 
    Arg<LLVM_AnyPointer, "the address to add to", [MemWrite]>:$dstAddr, 
    AnyVector:$valueToAdd, 
    I32Attr:$numElems
  );
}

def LoadF32Op : NPU_Op<"load_f32", [MemoryEffects<[MemRead]>]> {
  let summary = "Load float32 from vector(ub memory)";
  let description = [{
    The `load_f32` operation loads vector(ub memory)'s first scalar float32 value.
  }];

  let arguments = (ins AnyVector:$srcVector);
  let results = (outs F32:$res);
}

def NPU_MOVEVF32Op : NPU_Op<"movev_f32", [Pure]> {
  let summary = "broadcast float32 scalar to vector";
  let description = [{
    The `movev_f32` operation broadcast a float32 scalar to a vector.
  }];

  let arguments = (ins F32:$scalar, I32Attr:$numElems);
  let results = (outs AnyVector:$res);
}

def AllocaOp : NPU_Op<"alloca", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Allocate memory on ub";
  let description = [{
    The `alloca` operation allocates memory on ub.
  }];

  let arguments = (ins I32Attr:$numElems);
  let results = (outs Res<LLVM_AnyPointer, "", [MemAlloc<AutomaticAllocationScopeResource>]>:$addrPtr);
}

// The reason why there are 2 types `mov_ub_to_ub`, is that at the beginning, 
// the ub variable in NPU dialect is in the form of vector, after introducing
// shared memory, the ub has another form: pointer, so design 2 `move_ub_to_ub`
// to move data between these 2 forms ub.
def MovUBToUBReadOp : NPU_Op<"mov_ub_to_ub_read", [MemoryEffects<[MemRead]>]> {
  let summary = "Move/Read data from ub(ptr) to ub(vector)";
  let description = [{
    The `npu.mov_ub_to_ub_read` op represents moving data from ub memory to ub vector.
  }];

  let arguments = (ins 
    Arg<LLVM_AnyPointer, "the ub address to move data from", [MemRead]>:$srcAddr, 
    I32Attr:$numElems
  );
  let results = (outs AnyVector:$res);
}

def MovUBToUBWriteOp : NPU_Op<"mov_ub_to_ub_write", [MemoryEffects<[MemWrite]>]> {
  let summary = "Move/Write data from ub(vector) to ub(ptr)";
  let description = [{
    The `npu.mov_ub_to_ub_write` op represents moving data from ub vector to ub memory.
  }];

  let arguments = (ins 
    Arg<LLVM_AnyPointer, "the ub address to move data to", [MemWrite]>:$dstAddr,
    AnyVector:$valueToStore,
    I32Attr:$numElems
  );
}


def MovOutToUBOp : NPU_Op<"mov_out_to_ub", [MemoryEffects<[MemRead]>]> {
  let summary = "Move data from main memory to UB";
  let description = [{
    The `npu.mov_out_to_ub` op represents loading data from global
    memory to ub. This op represents the distributed version of a 
    `vector.transfer_read` as an intermediate step between lowering 
    from `vector.transfer_read` to `npu.mov_out_to_ub`.
  }];

  // TODO: The 2nd argument is num of elements or num of bytes? or num of 
  // 256 bytes?
  let arguments = (ins 
    Arg<LLVM_AnyPointer, "the address to move data from", [MemRead]>:$srcAddr, 
    I32Attr:$numElems
  );
  
  let results = (outs AnyVector:$res);
}

def MovUBToOutOp : NPU_Op<"mov_ub_to_out", [MemoryEffects<[MemWrite]>]> {
  let summary = "Move data from UB to main memory";
  let description = [{
    The `npu.mov_ub_to_out` op represents storing data from ub to global
    memory. This op represents the distributed version of a 
    `vector.transfer_write` as an intermediate step between lowering from 
    `vector.transfer_write` to `npu.mov_ub_to_out`.
  }];

  let arguments = (ins 
    Arg<LLVM_AnyPointer, "the address to store data to", [MemWrite]>:$dstAddr, 
    AnyVector:$valueToStore, 
    I32Attr:$numElems
  );

}


def MlpOp : NPU_Op<"mlp", [Pure]> {
  let summary = "Perform a Cambricon NPU mlp operation.";
  let description = [{}];

  let arguments = (ins
    AnyVector:$input,
    AnyVector:$filter,
    I32Attr:$numRows,
    I32Attr:$numCols);

  let results = (outs AnyVector:$res);
}

def ReshapeFilterOp : NPU_Op<"reshape_filter", [Pure]> {
  let summary = "Perform a Cambricon NPU reshape filter operation.";
  let description = [{}];

  let arguments = (ins
    AnyVector:$input,
    I32Attr:$batch,
    I32Attr:$channels,
    I32Attr:$height,
    I32Attr:$width);

  let results = (outs AnyVector:$res);
}

def TransposeOp : NPU_Op<"transpose", [Pure]> {
  let summary = "Perform a 2D transpose operation.";
  let description = [{}];

  let arguments = (ins
    AnyVector:$input,
    I32Attr:$numRows,
    I32Attr:$numCols);
  
  let results = (outs AnyVector:$res);
}

def VReduceF32Op : NPU_Op<"vreduce_f32", [Pure]> {
  let summary = "Perform 1D vector reduce operation.";
  let description = [{}];

  let arguments = (ins
    AnyVector:$input,
    I32Attr:$numElems,
    StrAttr:$kind);
  
  let results = (outs F32:$res);
}

#endif // NPU_DIALECT
