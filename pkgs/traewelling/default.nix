{ lib
, stdenv
, fetchFromGitHub
, php
, dataDir ? "/var/lib/traewelling"
, runtimeDir ? "/run/traewelling"
, pkgs
,
}:
let
  package = (import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    noDev = true;
  }).overrideAttrs (attrs: {
    installPhase = attrs.installPhase + ''
      rm -R $out/bootstrap/cache
      # Move static contents for the NixOS module to pick it up, if needed.
      mv $out/bootstrap $out/bootstrap-static
      mv $out/storage $out/storage-static
      ln -s ${dataDir}/.env $out/.env
      ln -s ${dataDir}/storage $out/
      ln -s ${dataDir}/storage/app/public $out/public/storage
      ln -s ${runtimeDir} $out/bootstrap
      chmod +x $out/artisan
    '';
  });
in
package.override rec {
  pname = "traewelling";
  version = "8ec1e34322893b5a01f67c8ba952d7873a9e7599";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "8ec1e34322893b5a01f67c8ba952d7873a9e7599";
    hash = "sha256-92/6tN2rHsMlKzQcY0/wePrmmYZv/BS3eE11Uq8UUgA=";
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Free check-in service to log your public transit journeys";
    license = lib.licenses.agpl3Only;
    homepage = "https://trawelling.de";
    maintainers = with lib.maintainers; [ marie ];
    inherit (php.meta) platforms;
  };
}
