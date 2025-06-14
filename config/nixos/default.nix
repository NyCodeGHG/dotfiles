{
  config,
  inputs,
  lib,
  ...
}:
{
  imports =
    with inputs;
    [
      self.nixosModules.authentik
      self.nixosModules.coder
      self.nixosModules.cachixUpload
      #inputs.self.nixosModules.scanservjs
    ]
    ++ import ./module-list.nix;

  options = {
    uwumarie.profiles = {
      users.marie = lib.mkEnableOption (lib.mdDoc "marie user profile") // {
        default = true;
      };
    };
  };
}
