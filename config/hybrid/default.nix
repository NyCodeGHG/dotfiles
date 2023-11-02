{ config, lib, inputs, configType, ... }:
{
  imports = [ ]
    #++ (lib.optional (configType == "home-manager") inputs.nixvim.homeManagerModules.nixvim)
    ++ [ inputs.nixvim.homeManagerModules.nixvim ./direnv.nix ./vim.nix ];
  #++ (lib.optional (configType == "nixos") inputs.nixvim.nixosModules.nixvim)
  #++ (import ./module-list.nix);
}
