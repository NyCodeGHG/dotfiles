{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uwumarie.profiles.nix = lib.mkEnableOption (lib.mdDoc "nix config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.nix {
    nix = {
      package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      gc = {
        automatic = lib.mkDefault true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      settings = {
        substituters = [
          "https://cache.marie.cologne/marie"
          "https://uwumarie.cachix.org"
        ];
        trusted-public-keys = [
          "marie:+lOdb5mtdCgfeh1P+Wsk/7okVYuvlv9eOSyihL6rwPs="
          "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
          "auto-allocate-uids"
          "cgroups"
        ];
        deprecated-features = lib.mkIf (lib.versionAtLeast config.nix.package.version "2.95") [
          "or-as-identifier"
        ];
        trusted-users = [ "@wheel" ];
        builders-use-substitutes = true;
        build-dir = "/var/tmp/nix";
        auto-allocate-uids = true;
        extra-system-features = [ "uid-range" ];
      };
    };
  };
}
