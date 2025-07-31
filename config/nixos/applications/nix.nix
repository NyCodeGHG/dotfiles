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
      package = pkgs.lixPackageSets.latest.lix.overrideAttrs (prev: {
        patches = prev.patches or [ ] ++ [
          (pkgs.fetchpatch {
            url = "https://gerrit.lix.systems/plugins/gitiles/lix/+/9987a3c7db0fc88c5721d0aad846953622b85277%5E%21/?format=TEXT";
            hash = "sha256-Ma9SpMkfhrY3TZeN4jD3GmrVwmOy2plgNbgF6sS9i7I=";
            decode = "base64 -d";
          })
        ];
      });
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      gc = {
        automatic = true;
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
        ];
        trusted-users = [ "@wheel" ];
        builders-use-substitutes = true;
        build-dir = "/var/tmp/nix";
      };
    };
  };
}
