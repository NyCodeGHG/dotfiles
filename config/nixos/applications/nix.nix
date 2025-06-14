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
    # Get rid of CppNix dependency
    system.tools.nixos-option.enable = lib.mkDefault false;
    nix = {
      package = pkgs.lix;
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
      };
    };
  };
}
