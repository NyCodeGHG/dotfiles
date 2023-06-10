{ config
, pkgs
, options
, ...
}:
{
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      enable_audio_bell = false;
    };
  };
}
