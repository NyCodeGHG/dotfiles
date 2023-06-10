{ lib, buildNpmPackage, fetchFromGitHub, nodejs_20 }:
let
  buildNpmPackage' = buildNpmPackage.override { nodejs = nodejs_20; };
in
buildNpmPackage' rec {
  pname = "authentik-web";
  version = "2023.5.3";

  src = fetchFromGitHub
    {
      owner = "goauthentik";
      repo = "authentik";
      rev = "v${version}";
      hash = "sha256-HpdZSs3rwYOqaSrEFK4Ufa6jkMyuji4mgyTkr5qgAdI=";
    };
  sourceRoot = "source/web";

  npmDepsHash = "sha256-qFs69w8oMAmrHl61KTz6VpYnbve1Swd+lXaUeMhO150=";
  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';
}

