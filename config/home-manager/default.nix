{ config, inputs, lib, ... }:
{
  imports = [
    inputs.unlock-ssh-keys.homeManagerModules.default
    inputs.agenix.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
  ] ++ import ./module-list.nix;

  options.uwumarie.profiles = {
    eza = lib.mkEnableOption (lib.mdDoc "eza config");
    jujutsu = lib.mkEnableOption (lib.mdDoc "jujutsu config");
    ripgrep = lib.mkEnableOption (lib.mdDoc "ripgrep config");
    ssh = lib.mkEnableOption (lib.mdDoc "ssh config");
    unlock-ssh-keys = lib.mkEnableOption (lib.mdDoc "unlock-ssh-keys config");
    zsh = lib.mkEnableOption (lib.mdDoc "zsh config");
    starship = lib.mkEnableOption (lib.mdDoc "starship config");
  };
}
