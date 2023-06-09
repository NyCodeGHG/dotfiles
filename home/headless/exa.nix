{ pkgs, config, lib, ... }:
{
  programs.exa = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
  };
}
