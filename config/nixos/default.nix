{ config, inputs, lib, ... }:
{
  imports = with inputs; [
    home-manager.nixosModules.default
    agenix.nixosModules.default

    self.nixosModules.authentik
    self.nixosModules.coder
    self.nixosModules.pgrok
    self.nixosModules.cachixUpload
    #inputs.self.nixosModules.scanservjs
  ] ++ import ./module-list.nix;

  options = {
    uwumarie.profiles = {
      users.marie = lib.mkEnableOption (lib.mdDoc "marie user profile") // {
        default = true;
      };
    };
  };
}
