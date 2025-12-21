{
  lib,
  pkgs,
  ...
}:
{
  services.factorio = {
    enable = false;
    bind = "[::]";
    package = pkgs.factorio-headless.overrideAttrs (prev: rec {
      version = "2.0.60";

      src = pkgs.fetchurl {
        url = "https://factorio.com/get-download/${version}/headless/linux64";
        name = "factorio-headless-${version}.tar.xz";
        hash = "sha256-abW+GoZ/2ZUk+ZFN/ukAoaw4bPTnTEpjdowF3E0rKws=";
      };

      # Remove Space Age
      installPhase = prev.installPhase + ''
        rm -rf $out/share/factorio/data/{quality,elevated-rails,space-age}
      '';
    });
    openFirewall = true;
    lan = true;
    admins = [
      "uwumarie"
    ];
    allowedPlayers = [
      "uwumarie"
      "roberto806"
    ];
    game-name = "meow";
    description = "factoworio server";
    loadLatestSave = true;
    nonBlockingSaving = true;
    autosave-interval = 15;
    requireUserVerification = true;
    extraSettings = {
      autosave_slots = 15;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    (builtins.elem (lib.getName pkg) [
      "factorio-headless"
    ]);
}
