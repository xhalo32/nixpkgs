{
  lib,
  pkgs,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  plasTeX,
  plastexshowmore,
  plastexdepgraph,
  click,
  rich,
  rich-click,
  tomlkit,
  jinja2,
  gitpython,
}:
buildPythonPackage rec {
  pname = "leanblueprint";
  version = "0.0.18";
  pyproject = true;

  src = fetchFromGitHub {
    repo = "leanblueprint";
    owner = "PatrickMassot";
    tag = "v${version}";
    hash = "sha256-kikeLc0huJHe4Fq207U8sdRrH26bzpo+IVKjsLnrWgY=";
  };

  build-system = [ setuptools ];

  dependencies = [
    plasTeX
    plastexshowmore
    plastexdepgraph
    click
    rich
    rich-click
    tomlkit
    jinja2
    gitpython
  ];

  nativeCheckInputs = [
    pkgs.git
    pkgs.texlive.combined.scheme-small
    pkgs.texlivePackages.latexmk
  ];

  pythonImportsCheck = [ "leanblueprint" ];

  checkPhase = ''
    runHook preCheck

    # A git repository is required by leanblueprint
    git init

    # A lakefile is required by leanblueprint
    echo > lakefile.lean

    # Copy minimal blueprint
    mkdir -p blueprint/src
    cp -r ${./test/blueprint/src}/. blueprint/src

    # Check web HTML output
    $out/bin/leanblueprint web
    grep -q "Leanblueprint Test" blueprint/web/index.html
    grep -q "Test Chapter" blueprint/web/index.html
    grep -q "Test Chapter" blueprint/web/sect0001.html
    grep -q "def:one_add_one_eq_two" blueprint/web/sect0001.html
    grep -q "sect0001.html#def:one_add_one_eq_two" blueprint/web/dep_graph_document.html
    test -d blueprint/web/js
    test -d blueprint/web/styles

    # Check print PDF output
    $out/bin/leanblueprint pdf
    test -f blueprint/print/print.pdf

    runHook postCheck
  '';

  meta = {
    description = "A plasTeX plugin allowing to write blueprints for Lean 4 projects";
    homepage = "https://github.com/PatrickMassot/leanblueprint";
    maintainers = with lib.maintainers; [ niklashh ];
    license = lib.licenses.asl20;
  };
}
