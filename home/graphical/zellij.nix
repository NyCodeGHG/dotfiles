{ pkgs, config, lib, ... }:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin";
    };
  };
}
