//===- NPU.td - NPU dialect ------------------------------------*- tablegen -*-===//
//
// This file declares the NPU dialect.
//
//===----------------------------------------------------------------------===//

#ifndef NPU_DIALECT
#define NPU_DIALECT

include "mlir/IR/BuiltinAttributeInterfaces.td"
include "mlir/IR/EnumAttr.td"
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

def NPUCmpIPredicateAttr : I64EnumAttr<
    "NPUCmpIPredicate", "",
    [
      I64EnumAttrCase<"eq", 0>,
      I64EnumAttrCase<"ne", 1>,
      I64EnumAttrCase<"slt", 2>,
      I64EnumAttrCase<"sle", 3>,
      I64EnumAttrCase<"sgt", 4>,
      I64EnumAttrCase<"sge", 5>,
      I64EnumAttrCase<"ult", 6>,
      I64EnumAttrCase<"ule", 7>,
      I64EnumAttrCase<"ugt", 8>,
      I64EnumAttrCase<"uge", 9>,
    ]> {
  let cppNamespace = "::mlir::npu";
}

/*************** Binary operations ***************/
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

def VAddI32Op : NPU_Op<"vadd_i32", [Pure]> {
  let summary = "Vector int32 add operation";
  let description = [{
    The `vadd_i32` operation adds two int32 vectors element-wise.
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
}

def VDivI32Op : NPU_Op<"vdiv_i32", [Pure]> {
  let summary = "Vector int32 div operation";
  let description = [{
    The `vdiv_i32` operation divs two int32 vectors element-wise.
  }];

  let arguments = (ins AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

def VCmpI32Op : NPU_Op<"vcmp_i32", [Pure]> {
  let summary = "Vector int32 compare operation";
  let description = [{
    The `vcmp_i32` operation compares two vectors element-wise, 
    return result vector, which is a mask vector. 
    Input: predicate, i32 vector, i32 vector.
    Output: i1 vector.
  }];

  let arguments = (ins NPUCmpIPredicateAttr:$predicate, 
                       AnyVector:$lhs, 
                       AnyVector:$rhs);
  let results = (outs AnyVector:$res);
}

/*************** Ternary operations ***************/
def VSelOp : NPU_Op<"vsel", [Pure]> {
  let summary = "Vector select operation";
  let description = [{
    The `vsel` operation selects elements from two vectors based on a mask vector.
  }];

  let arguments = (ins AnyVector:$mask, AnyVector:$lhs, AnyVector:$rhs, I32Attr:$numElems);
  let results = (outs AnyVector:$res);

  let builders = [
    OpBuilder<(ins "Value":$mask, "Value":$lhs, "Value":$rhs, "IntegerAttr":$numElems)>
  ];
}

/*************** Unary operations ***************/
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

def ConstantI32ScalarVectorOp : NPU_Op<"constant_i32_scalar_vector", [Pure]> {
  let summary = "Create a constant i32 vector from a scalar value";
  let description = [{
    The `constant_i32_scalar_vector` operation creates a constant i32 vector 
    from a scalar value.
  }];

  let arguments = (ins I32Attr:$value, I32Attr:$numElems);
  let results = (outs VectorOf<[I32]>:$res);
}

def ConstantF32ScalarVectorOp : NPU_Op<"constant_f32_scalar_vector", [Pure]> {
  let summary = "Create a constant f32 vector from a scalar value";
  let description = [{
    The `constant_f32_scalar_vector` operation creates a constant f32 vector 
    from a scalar value.
  }];

  let arguments = (ins F32Attr:$value, I32Attr:$numElems);
  let results = (outs VectorOf<[F32]>:$res);
}

def ConstantI32VectorOp : NPU_Op<"constant_i32_vector", [Pure]> {
  let summary = "Create a constant i32 vector from a list of scalar values";
  let description = [{
    The `constant_i32_vector` operation creates a constant i32 vector 
    from a list of scalar values.
  }];

  let arguments = (ins TypedAttrInterface:$values);
  let results = (outs VectorOf<[I32]>:$res);
}

def ConstantF32VectorOp : NPU_Op<"constant_f32_vector", [Pure]> {
  let summary = "Create a constant f32 vector from a list of scalar values";
  let description = [{
    The `constant_f32_vector` operation creates a constant f32 vector 
    from a list of scalar values.
  }];

  let arguments = (ins TypedAttrInterface:$values);
  let results = (outs VectorOf<[F32]>:$res);
}

def NPU_BlockIdOp : NPU_Op<"block_id", [Pure]> {
  let summary = "Get block id";
  let description = [{
    The `npu.block_id` operation returns the block id.
  }];

  let results = (outs I64:$res);
}

def NPU_BlockNumOp : NPU_Op<"block_num", [Pure]> {
  let summary = "Get block num";
  let description = [{
    The `npu.block_num` operation returns the block num.
  }];

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

// Note: BroadCastI32Op and NPU_MOVEVF32Op are both used to broadcast, the 
// different is only the type. The name change is for better understanding: 
// because it will not just used for Ascend.
// TODO: BroadCastI32Op's argument is I32, does need to add another op for I32Attr?
// 现在BroadCastI32Op的参数是Value类型的，如果对于编译时常量，是否需要另外一个op？现在如果broadcast一个常量的话，还需要一个额外的arith.constant op来转成Value类型，这个后面会被优化吗？
def BroadCastI32Op : NPU_Op<"broadcast_i32", [Pure]> {
  let summary = "broadcast int32 scalar to vector";
  let description = [{
    The `broadcast_i32` operation broadcast an i32 scalar to a vector.
  }];

  let arguments = (ins I32:$scalar, I32Attr:$numElems);
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

// TODO: AllocaUBVectorOp 和 AllocaOp 最后要保留哪一个呢？AllocaOp 为什么设计成返回指针的形式呢？应该是因为当时采用的是生成LLVM IR的方式吧；所以要生成指针，往后面lowering的时候方便一些？
def AllocaUBVectorOp : NPU_Op<"alloca_ub_vector", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Allocate memory on ub, get a vector";
  let description = [{
    The `alloca_ub_vector` operation allocates memory on ub, get a vector.
  }];
  let arguments = (ins I32Attr:$numElems);
  let results = (outs AnyVector:$res);
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

def MovUBToOutMaskedOp : NPU_Op<"mov_ub_to_out_masked", [MemoryEffects<[MemWrite]>]> {
  let summary = "Move data from UB to global memory with mask";
  let description = [{
    The `npu.mov_ub_to_out_masked` op represents storing data from ub to global
    memory with mask.
  }];

  let arguments = (ins 
    Arg<LLVM_AnyPointer, "the address to store data to", [MemWrite]>:$dstAddr, 
    AnyVector:$valueToStore, 
    I32Attr:$numElems,
    AnyVector:$mask
  );

}

// AssignUBI32Op 和 StoreUBI32Op 的区别: 前者赋的值是常量，后者是变量
def AssignUBI32Op : NPU_Op<"assign_ub_i32", [MemoryEffects<[MemWrite]>]> {
  let summary = "Assign an i32 scalar to an ub vector";
  let description = [{
    The `npu.assign_ub_i32` op represents assigning an i32 scalar to an ub vector.
  }];

  let arguments = (ins AnyVector:$dstVector, I32Attr:$index, I32Attr:$srcScalar);
}

def LoadUBI32Op : NPU_Op<"load_ub_i32", [MemoryEffects<[MemRead]>]> {
  let summary = "Load int32 from vector(ub memory) with given index";
  let description = [{
    The `load_ub_i32` operation loads vector(ub memory)'s index-st int32 value.
  }];

  let arguments = (ins AnyVector:$srcVector, I32Attr:$index);
  let results = (outs I32:$res);
}

def StoreUBI32Op : NPU_Op<"store_ub_i32", [MemoryEffects<[MemWrite]>]> {
  let summary = "Store an i32 scalar to an ub vector with given index";
  let description = [{
    The `npu.store_ub_i32` op represents storing an i32 scalar to an ub vector with given index.
  }];

  let arguments = (ins AnyVector:$dstVector, I32Attr:$index, I32:$srcScalar);
}

#endif // NPU_DIALECT
