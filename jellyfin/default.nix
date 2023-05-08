{ pkgs, config, lib, buildDotnetModule, fetchFromGitHub, dotnetCorePackages, stdenvNoCC, ... }:
let
  jellyfin-intro-skipper-lib = buildDotnetModule rec {
    pname = "jellyfin-intro-skipper";
    version = "0.1.7";
    src = fetchFromGitHub {
      owner = "ConfusedPolarBear";
      repo = "intro-skipper";
      rev = "v${version}";
      sha256 = "sha256-ca7msNdoSgi/TdzRBSIQ9itsrw5cLQjqagUEb5KOSnI=";
    };
    projectFile = "ConfusedPolarBear.Plugin.IntroSkipper/ConfusedPolarBear.Plugin.IntroSkipper.csproj";
    dotnet-sdk = dotnetCorePackages.sdk_6_0;
    dotnet-runtime = dotnetCorePackages.runtime_6_0;
    nugetDeps = ./deps.nix;
    executables = [ ];
  };
  jellyfin-intro-skipper = stdenvNoCC.mkDerivation {
    pname = jellyfin-intro-skipper-lib.pname;
    version = jellyfin-intro-skipper-lib.version;
    src = jellyfin-intro-skipper-lib;
    installPhase = ''
      mkdir $out
      cp ${jellyfin-intro-skipper-lib}/lib/${jellyfin-intro-skipper-lib.pname}/ConfusedPolarBear.Plugin.IntroSkipper.{dll,pdb,xml} $out
    '';
  };
  jellyfin-web = pkgs.jellyfin-web.overrideAttrs
    (final: previous: {
      version = "10.8.10";
      src = fetchFromGitHub {
        owner = "ConfusedPolarBear";
        repo = "jellyfin-web";
        rev = "4d9c94b8f109435b68ea864bcea3bc41dfceb128";
        sha256 = "sha256-8oVT687/VzSxKx+b9i/PNDFxqIDJn7NeAGQreygVz7E=";
      };
    });
  jellyfin = pkgs.jellyfin.override {
    inherit jellyfin-web;
  };
in
{
  inherit jellyfin-intro-skipper jellyfin jellyfin-web;
}
