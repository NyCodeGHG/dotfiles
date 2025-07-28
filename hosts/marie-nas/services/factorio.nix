{
  lib,
  pkgs,
  ...
}:
{
  services.factorio = {
    enable = true;
    package = pkgs.factorio-headless.overrideAttrs (prev: rec {
      version = "2.0.60";

      src = pkgs.fetchurl {
        url = "https://factorio.com/get-download/${version}/headless/linux64";
        hash = "sha256-abW+GoZ/2ZUk+ZFN/ukAoaw4bPTnTEpjdowF3E0rKws=";
      };

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
    ];
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    (builtins.elem (lib.getName pkg) [
      "factorio-headless"
    ]);
}
