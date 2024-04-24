//===--- Ascend.cpp - Implement Ascend target feature support
//-----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements Huawei Ascend TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "Ascend.h"

using namespace clang;
using namespace clang::targets;

// FIXME(HACL):
// We use data layout used in CCEC compiler here.
static std::string getDL() {
  return "e-i1:8:32-i8:8:32-i16:16:32-i64:64-f16:16:32-v16:16-v32:32-n64-S64";
}

AscendTargetInfo::AscendTargetInfo(const llvm::Triple &Triple)
    : TargetInfo(Triple) {
  resetDataLayout(getDL());
  // Ascend target always uses Itanium C++ ABI.
  TheCXXABI.set(TargetCXXABI::GenericItanium);
  // FIXME(HACL):
  // Other target info should be reset.
  // (1) BitWidth of types, such as LongWidth, PointerWidth, and so on.
  // (2) Typedef, such as SizeType, PtrDiffType, IntPtrType, and so on.
}