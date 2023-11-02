{ config, lib, ... }:
lib.mkIf config.uwumarie.profiles.eza {
  programs.eza = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
  };
}
