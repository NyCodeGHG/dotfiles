{
  lib,
  fetchFromGitHub,
  stdenv,
  yarnConfigHook,
  yarnBuildHook,
  fetchYarnDeps,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lovelace-horizon-card";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "rejuvenate";
    repo = "lovelace-horizon-card";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tiJCfEX+B4derjb/g4+gck9kEOcbsH+8VJ8fmbDH5Fc=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-gx1tDgNa3qRb0IdoLDK7TX0/XhV4bAjEMQSaaS1nQc0=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/lovelace-horizon-card.js $out

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/rejuvenate/lovelace-horizon-card/releases/tag/v${finalAttrs.version}";
    description = "Sun Card successor: Visualize the position of the Sun over the horizon";
    homepage = "https://github.com/rejuvenate/lovelace-horizon-card";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marie ];
  };
})

