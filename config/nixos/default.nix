{
  lib,
  ...
}:
{
  imports = import ./module-list.nix;

  options = {
    uwumarie.profiles = {
      users.marie = lib.mkEnableOption (lib.mdDoc "marie user profile") // {
        default = true;
      };
    };
  };
}
