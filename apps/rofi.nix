{ pkgs, config, ... }:

let
  rofiConfig = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/rofi/5350da41a11814f950c3354f090b90d4674a95ce/basic/.local/share/rofi/themes/catppuccin-mocha.rasi";
    sha256 = "sha256:c6d86cfe99c2e962a9dd3c1cd62a8dca3c737a9f82459338edc0a300fa434f10";
  };
in
{
  xdg.dataFile."rofi/themes/catppuccin-mocha.rasi".source = rofiConfig;
  programs.rofi = {
    enable = true;
    theme = "catppuccin-mocha";
    plugins = with pkgs; [ rofi-calc ];
    package =
      pkgs.rofi-wayland.overrideAttrs
      (oldAttrs: {mesonFlags = ["-Dxcb=disabled"];});
    extraConfig = {
      modi = "drun";
      icon-theme = "Oranchelo";
      show-icons = true;
      terminal = "kitty";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 﩯 Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };
  };
}
