{
  pkgs,
  config,
  lib,
  ...
}: {
  xdg.configFile."btop/themes/catppuccin_mocha.theme".text = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "btop";
      rev = "7109eac2884e9ca1dae431c0d7b8bc2a7ce54e54";
      sha256 = "0pqw3zkfgl75qyrfgzp7kdxkn8zwhdjslszslcc97i1kh33wz0s2";
    }
    + "/themes/catppuccin_mocha.theme");
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
      vim_keys = true;
      rounded_corners = true;
    };
  };
}
