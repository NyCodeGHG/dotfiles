{
  config,
  lib,
  pkgs,
  ...
}:
let
  ncroEnabled = config.services ? ncro && config.services.ncro.enable;
in
{
  options.uwumarie.profiles.nix = lib.mkEnableOption (lib.mdDoc "nix config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.nix {
    nix = {
      package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
      gc = {
        automatic = lib.mkDefault true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      settings = {
        nix-path = [ "nixpkgs=flake:nixpkgs" ];
        substituters = lib.optionals (!ncroEnabled) [
          "https://cache.marie.cologne/marie"
        ];
        trusted-public-keys = lib.optionals (!ncroEnabled) [
          "marie:+lOdb5mtdCgfeh1P+Wsk/7okVYuvlv9eOSyihL6rwPs="
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
        auto-allocate-uids = true;
        extra-system-features = [ "uid-range" ];
        use-cgroups = true;
        use-xdg-base-directories = true;

        download-attempts = 3;
        initial-connect-timeout = 3;
        max-connect-timeout = 10;
        stalled-download-timeout = 5;
      };
    };
  };
}
