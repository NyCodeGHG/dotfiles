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
  version = "970c8ab14406d029bdcca38fe7a3dbbc5c4608ab";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "970c8ab14406d029bdcca38fe7a3dbbc5c4608ab";
    hash = "sha256-ZbG5tRXym0MlrKlG8d3gx3EN4//WpTjnV0hj78YWGho=";
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
