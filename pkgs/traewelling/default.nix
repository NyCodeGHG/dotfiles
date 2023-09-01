{ lib
, stdenv
, fetchFromGitHub
, php
, dataDir ? "/var/lib/traewelling"
, runtimeDir ? "/run/traewelling"
, pkgs
, lndir
,
}:
let
  pname = "traewelling";
  rev = "cf1a044d94c64e73b03ce4f37a669eb570848f0c";
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    inherit rev;
    hash = "sha256-d2eXsPDRcSMWmUoXqDCk4hmzehRzJq0zNI9WJVihfH4=";
  };
  web = pkgs.callPackage ./web.nix { inherit src; version = rev; };
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
      ${lndir}/bin/lndir -silent ${web} $out/public
      chmod +x $out/artisan
    '';
  });
in
package.override rec {
  version = rev;
  inherit pname src;  

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Free check-in service to log your public transit journeys";
    license = lib.licenses.agpl3Only;
    homepage = "https://trawelling.de";
    maintainers = with lib.maintainers; [ marie ];
    inherit (php.meta) platforms;
  };
}
