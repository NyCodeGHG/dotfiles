{ config, lib, ... }:
lib.mkIf config.uwumarie.profiles.eza {
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = false;
    icons = "auto";
    extraOptions = [
      "--group"
      "--header"
    ];
  };
}
