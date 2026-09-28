{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  cacert,
  git,
  curl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tandem";
  version = "0.4.0-unstable-2026-09-15";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "laulauland";
    repo = "tandem";
    rev = "d0cd683dbfefc990e12cec7af4e46764deb63598";
    hash = "sha256-Y7zyQV3BifKkwtyJR6NWbQVfhoxAuL6Us6fJqVQ4Exw=";
  };

  postPatch = ''
    substituteInPlace crates/cli/tests/common/mod.rs \
      --replace-fail "/usr/bin/git" "${lib.getExe git}"
  '';

  nativeCheckInputs = [
    cacert
    git
    curl
  ];

  cargoHash = "sha256-//WScGk0jvU10xw1kkbaPqgDb4UcFcdks9nJGv/Uk5Q=";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version branch=main" ];
  };

  meta = {
    description = "Workspaces over network";
    homepage = "https://github.com/laulauland/tandem";
    changelog = "https://github.com/laulauland/tandem/releases/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "tandem";
  };
})
