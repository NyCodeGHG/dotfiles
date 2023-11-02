{ config, lib, ... }:
lib.mkIf config.uwumarie.profiles.ripgrep {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--smart-case"
      "--glob=!.git/*"
      "--hidden"
    ];
  };
}
