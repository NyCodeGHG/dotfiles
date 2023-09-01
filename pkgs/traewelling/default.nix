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
    installPhase =  ''
      ${attrs.installPhase}

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
  version = "4015a02263200ce3a1a360bbb565c879a66e5c8e";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "4015a02263200ce3a1a360bbb565c879a66e5c8e";
    hash = "sha256-+TQopFY7jqnAJ1i2zwood0fVnfcjhfUX12ThGsYWXtA=";
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
