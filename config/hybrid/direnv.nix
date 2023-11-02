{ config, lib, ... }:
{
  options.uwumarie.profiles.direnv = lib.mkEnableOption (lib.mdDoc "the direnv profile");
  config.programs.direnv = lib.mkIf config.uwumarie.profiles.direnv {
    enable = true;
    nix-direnv.enable = true;
  };
}
