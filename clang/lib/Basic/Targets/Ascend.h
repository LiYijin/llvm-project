//===--- Ascend.h - Declare Ascend target feature support ------------*- C++
//-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares Huawei Ascend TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_ASCEND_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_ASCNED_H

#include "OSTargets.h"
#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/TargetOptions.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/TargetParser/Triple.h"
#include "llvm/Support/Compiler.h"

namespace clang {
namespace targets {

// Ascend
// Not all features of a target are required for Ascend.
// We are primarily interested in being able to specify a particular gpu
// variant.
//
class LLVM_LIBRARY_VISIBILITY AscendTargetInfo : public TargetInfo {
  static const Builtin::Info BuiltinInfo[];
  std::string CPU;

public:
  AscendTargetInfo(const llvm::Triple &Triple);

  virtual bool setCPU(const std::string &Name) {
    CPU = Name;
    return true;
  }

  virtual const std::string &getCPU() const { return CPU; }

  ArrayRef<Builtin::Info> getTargetBuiltins() const override {
    return ArrayRef<Builtin::Info>();
  }

  virtual BuiltinVaListKind getBuiltinVaListKind() const {
    return TargetInfo::VoidPtrBuiltinVaList;
  }

  // FIXME(HACL):
  // Define Macros for ascend.
  virtual void getTargetDefines(const LangOptions &Opts,
                                MacroBuilder &Builder) const {}

  virtual void getDefaultFeatures(llvm::StringMap<bool> &Features) const {}

  virtual bool handleTargetFeatures(std::vector<std::string> &Features,
                                    DiagnosticsEngine &Diags) {
    return true;
  }

  // FIXME(HACL):
  // Different chip may support different target feature.
  // Check whether the given chip support the feature.
  virtual bool hasFeature(StringRef Feature) const { return true; }

  std::string_view getClobbers() const override { return ""; }

  ArrayRef<const char *> getGCCRegNames() const override {
    return ArrayRef<const char *>();
  }

  ArrayRef<GCCRegAlias> getGCCRegAliases() const override {
    return ArrayRef<GCCRegAlias>();
  }

  virtual bool validateAsmConstraint(const char *&Name,
                                     TargetInfo::ConstraintInfo &Info) const {
    return false;
  }
};

} // namespace targets
} // namespace clang
#endif // LLVM_CLANG_LIB_BASIC_TARGETS_ASCEND_H
