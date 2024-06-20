{ config, lib, inputs, ... }:
{
  options.uwumarie.profiles.nix = lib.mkEnableOption (lib.mdDoc "nix config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.nix {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      settings = {
        substituters = [ "https://uwumarie.cachix.org" ];
        trusted-public-keys = [ "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo=" ];
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "@wheel" ];
      };
      # registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
      ];
    };
  };
}
