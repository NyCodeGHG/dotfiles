{ config, lib, ... }:
lib.mkIf config.uwumarie.profiles.eza {
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--group"
      "--header"
    ];
  };
}
