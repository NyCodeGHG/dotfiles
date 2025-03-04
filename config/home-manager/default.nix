{ config, inputs, lib, ... }:
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ] ++ import ./module-list.nix;

  options.uwumarie.profiles = {
    eza = lib.mkEnableOption (lib.mdDoc "eza config");
    jujutsu = lib.mkEnableOption (lib.mdDoc "jujutsu config");
    zsh = lib.mkEnableOption (lib.mdDoc "zsh config");
    starship = lib.mkEnableOption (lib.mdDoc "starship config");
  };
}
