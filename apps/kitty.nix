{
  config,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "Iosevka Nerd Font";
      size = 12;
    };
  };
}
