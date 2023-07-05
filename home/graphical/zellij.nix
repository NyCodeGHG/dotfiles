{ pkgs, config, lib, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin";
    };
  };
}
