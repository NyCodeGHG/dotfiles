{ config, lib, inputs, configType, ... }:
{
  imports = [ ]
    ++ (lib.optional (configType == "home-manager") inputs.nixvim.homeManagerModules.nixvim)
    ++ (lib.optional (configType == "nixos") inputs.nixvim.nixosModules.nixvim)
    ++ (import ./module-list.nix);
}
