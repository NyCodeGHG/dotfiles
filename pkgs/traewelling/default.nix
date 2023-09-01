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
  version = "887a3603f9db8b3b20ac6a7d6da50eb18e91853f";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "887a3603f9db8b3b20ac6a7d6da50eb18e91853f";
    hash = "sha256-imZlyfR8VON7DD+f4qQFLoYeFAozZ6kcUz27pX+5IKA=";
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
