{
  lib,
  llvmPackages_19,
  cmake,
  fetchFromGitHub,
  git,
  gmp,
  cadical,
  makeWrapper,
  pkg-config,
  libuv,
  enableMimalloc ? true,
  perl,
  testers,
}:

let
  cadical' = cadical.override { version = "2.1.3"; };
in
llvmPackages_19.stdenv.mkDerivation (finalAttrs: {
  pname = "lean4";
  version = "4.30.0";

  # Using a vendored version rather than nixpkgs' version to match the exact version required by
  # Lean.  Apparently, even a slight version change can impact greatly the final performance.
  mimalloc-src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mimalloc";
    tag = "v2.2.3";
    hash = "sha256-B0gngv16WFLBtrtG5NqA2m5e95bYVcQraeITcOX9A74=";
  };

  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "lean4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YTsfIppd6km7wOjAxRH5KMPsW++ztFDCJT2up72J86Q=";
  };

  VERBOSE = "1";

  # Fix for "gcc: error: unrecognized command-line option '--print-target-triple'"
  # substituteInPlace stage0/src/CMakeLists.txt \
  # --replace-fail 'set(LEAN_PLATFORM_TARGET ""' 'set(LEAN_PLATFORM_TARGET "x86_64-unknown-linux-gnu"'

  # TODO can we install leantar?
  postPatch =
    let
      pattern = "\${LEAN_BINARY_DIR}/../mimalloc/src/mimalloc";
    in
    ''
      substituteInPlace src/CMakeLists.txt \
        --replace-fail 'set(GIT_SHA1 "")' 'set(GIT_SHA1 "${finalAttrs.src.tag}")'
      substituteInPlace stage0/src/CMakeLists.txt \
        --replace-fail 'option(INSTALL_LEANTAR "Install a copy of leantar" ON)' 'option(INSTALL_LEANTAR "Install a copy of leantar" OFF)'
      substituteInPlace src/CMakeLists.txt \
        --replace-fail 'option(INSTALL_LEANTAR "Install a copy of leantar" ON)' 'option(INSTALL_LEANTAR "Install a copy of leantar" OFF)'

      # Remove tests that fails in sandbox.
      # It expects `sourceRoot` to be a git repository.
      rm -rf src/lake/examples/git/
    ''
    + (lib.optionalString enableMimalloc ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'MIMALLOC-SRC' '${finalAttrs.mimalloc-src}'
      for file in stage0/src/CMakeLists.txt stage0/src/runtime/CMakeLists.txt src/CMakeLists.txt src/runtime/CMakeLists.txt; do
        substituteInPlace "$file" \
          --replace-fail '${pattern}' '${finalAttrs.mimalloc-src}'
      done
    '');

  preConfigure = ''
    patchShebangs stage0/src/bin/ src/bin/
  '';

  # dontUseCmakeConfigure = true;

  # configurePhase = ''
  #   runHook preConfigure

  #   cmake --preset release -DUSE_GITHASH=OFF -DINSTALL_LICENSE=OFF -DINSTALL_CADICAL=OFF -DINSTALL_LEANTAR=OFF -DUSE_MIMALLOC=ON

  #   runHook postConfigure
  # '';

  # Build directory for `--preset=release`
  preBuild = ''
    cd release
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    llvmPackages_19.bintools
    llvmPackages_19.llvm
    makeWrapper
  ];

  buildInputs = [
    gmp
    libuv
    cadical'
  ];

  postInstall = ''
    wrapProgram $out/bin/lean \
      --prefix PATH : ${cadical'}/bin
  '';

  nativeCheckInputs = [
    git
    perl
  ];

  patches = [ ./mimalloc.patch ];

  cmakeFlags = [
    "--preset=release"
    "-DUSE_GITHASH=OFF"
    "-DINSTALL_LICENSE=OFF"
    "-DINSTALL_CADICAL=OFF"
    # "-DINSTALL_LEANTAR=OFF"
    "-DUSE_MIMALLOC=${if enableMimalloc then "ON" else "OFF"}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };
  };

  meta = {
    description = "Automatic and interactive theorem prover";
    homepage = "https://leanprover.github.io/";
    changelog = "https://github.com/leanprover/lean4/blob/${finalAttrs.src.tag}/RELEASES.md";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      danielbritten
      jthulhu
      nadja-y
    ];
    mainProgram = "lean";
  };
})
