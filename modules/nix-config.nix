{ inputs, ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      substituters = [ "https://hyprland.cachix.org" "https://uwumarie.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo=" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };
  environment.etc."channels/nixpkgs".source = inputs.nixpkgs.outPath;
}
