{ config, inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko

    inputs.home-manager.nixosModules.home-manager

    inputs.lanzaboote.nixosModules.lanzaboote

    inputs.agenix.nixosModules.default
    #inputs.agenix-rekey.nixosModules.default

    inputs.awesome-prometheus-rules.nixosModules.default

    inputs.self.nixosModules.authentik
    inputs.self.nixosModules.coder
    inputs.self.nixosModules.pgrok
    #inputs.self.nixosModules.scanservjs
    inputs.self.nixosModules.hybrid
  ] ++ import ./module-list.nix;

  options = {
    uwumarie.profiles = {
      users.marie = lib.mkEnableOption (lib.mdDoc "marie user profile") // {
        default = true;
      };
    };
  };
}
