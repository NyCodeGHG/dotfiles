{
  python3Packages,
  fetchFromGitHub,
  buildNpmPackage,
}:

let
  frontend = { src, pname, version, ... }: buildNpmPackage {
    pname = "${pname}-frontend";
    inherit src version;
    sourceRoot = "${src.name}/mcp-app";

    npmDepsHash = "sha256-2u/lreSth9HLHt7fAwC9Q+WrYlsAz2VHFUIT6dr9XEE=";

    installPhase = ''
      runHook preInstall

      mv dist $out

      runHook postInstall
    '';
  };
in

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "linux-mcp-server";
  version = "1.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rhel-lightspeed";
    repo = "linux-mcp-server";
    tag = finalAttrs.version;
    hash = "sha256-p5ZEjwWZOoNNEMxeM81WyHbgkGUaK+sT1Kuyls7YlQg=";
  };

  preBuild = ''
    ln -s ${frontend finalAttrs} mcp-app/dist
  '';

  nativeBuildInputs = [
    python3Packages.pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    "fastmcp"
    "fakeredis"
  ];

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  dependencies = with python3Packages; [
    asyncssh
    fastmcp
    litellm
    pydantic
    pydantic-settings
    fakeredis
  ];

  meta = {
    mainProgram = "linux-mcp-server";
  };
})
