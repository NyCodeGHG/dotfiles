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

    npmDepsHash = "sha256-6EmAXZRq5/DLs6/3waT8dxQvZ3HVtUQJOiIWpukCK2E=";

    installPhase = ''
      runHook preInstall

      mv dist $out

      runHook postInstall
    '';
  };
in

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "linux-mcp-server";
  version = "1.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rhel-lightspeed";
    repo = "linux-mcp-server";
    rev = "7e688f56e5019c5f95f18d39293a9befacb08d48";
    hash = "sha256-oNNc0zA5d1alvbkZi7KiJtRxcTbp3sBlDCpwaNxXyPQ=";
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
