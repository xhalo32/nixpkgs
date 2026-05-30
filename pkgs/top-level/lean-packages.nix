# Lean 4 package set with its own toolchain (independent of pkgs.lean4).
#
# Override the toolchain for the entire set:
#   leanPackages.overrideScope (self: super: { lean4 = lean4-custom; })
{
  lib,
  newScope,
}:

lib.makeScope newScope (self: {
  # lean4 = self.callPackage ../development/lean-modules/lean4 { };
  lean4 = self.callPackage ../by-name/le/lean4/package.nix { };
  # These are in chronological order
  lean4-clang = self.callPackage ../by-name/le/lean4/lean4-clang.nix { };
  lean4-gcc-leantar-off = self.callPackage ../by-name/le/lean4/lean4-gcc-leantar-off.nix { };
  lean4-gcc-leantar-off-2 = self.callPackage ../by-name/le/lean4/lean4-gcc-leantar-off-2.nix { };
  lean4-gcc-leantar-off-default-preset =
    self.callPackage ../by-name/le/lean4/lean4-gcc-leantar-off-default-preset.nix
      { };
  lean4-leantar-mock = self.callPackage ../by-name/le/lean4/lean4-leantar-mock.nix { };
  lean4-with-leangz = self.callPackage ../by-name/le/lean4/lean4-with-leangz.nix { };

  buildLakePackage = self.callPackage ../build-support/lake { };

  batteries = self.callPackage ../development/lean-modules/batteries { };
  aesop = self.callPackage ../development/lean-modules/aesop { };
  Qq = self.callPackage ../development/lean-modules/Qq { };
  proofwidgets = self.callPackage ../development/lean-modules/proofwidgets { };
  plausible = self.callPackage ../development/lean-modules/plausible { };
  LeanSearchClient = self.callPackage ../development/lean-modules/LeanSearchClient { };
  Cli = self.callPackage ../development/lean-modules/Cli { };
  importGraph = self.callPackage ../development/lean-modules/importGraph { };
  mathlib = self.callPackage ../development/lean-modules/mathlib { };
})
