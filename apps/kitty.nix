{
  config,
  pkgs,
  options,
  ...
}:
let
  fonts = import ../fonts.nix { inherit pkgs; };
in {
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = builtins.head fonts.monospace;
      size = 12;
    };
  };
}
