{
  lib,
  stdenv,
  fetchFromGitHub,
  faust2jack,
  faust2lv2,
  helmholtz,
  mrpeach,
  puredata-with-plugins,
  jack-example-tools,
}:
stdenv.mkDerivation rec {
  pname = "VoiceOfFaust";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "magnetophon";
    repo = "VoiceOfFaust";
    rev = version;
    sha256 = "sha256-vB8+ymvNuuovFXwOJ3BTIj5mGzCGa1+yhYs4nWMYIxU=";
  };

  plugins = [
    helmholtz
    mrpeach
  ];

  pitchTracker = puredata-with-plugins plugins;

  nativeBuildInputs = [
    faust2jack
    faust2lv2
  ];

  # ld: crtbegin.o: relocation R_X86_64_32 against hidden symbol `__TMC_END__' can not be used when making a PIE object
  # ld: failed to set dynamic section sizes: bad value
  hardeningDisable = [ "pie" ];

  enableParallelBuilding = true;

  dontWrapQtApps = true;

  makeFlags = [
    "PREFIX=$(out)"
  ];

  patchPhase = ''
    sed -i "s@pd -nodac@${pitchTracker}/bin/pd -nodac@g" launchers/synthWrapper
    sed -i "s@jack_connect@${jack-example-tools}/bin/jack_connect@g" launchers/synthWrapper
    sed -i "s@../PureData/OscSendVoc.pd@$out/bin/PureData/OscSendVoc.pd@g" launchers/pitchTracker
  '';

  meta = {
    description = "Turn your voice into a synthesizer";
    homepage = "https://github.com/magnetophon/VoiceOfFaust";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];
  };
}
