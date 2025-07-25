{
  lib,
  pkgs,
  ...
}:
{
  services.factorio = {
    enable = true;
    package = pkgs.factorio-headless.overrideAttrs (prev: {
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
