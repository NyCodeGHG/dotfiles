{ pkgs, config, lib, ... }:
{
  programs.starship =
    let
      flavour = "mocha";
      catppuccinPallette = pkgs.fetchFromGitHub
        {
          owner = "catppuccin";
          repo = "starship";
          rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc";
          sha256 = "soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
        } + /palettes/${flavour}.toml;
    in
    {
      enable = true;
      settings = {
        format = "$all";
        palette = "catppuccin_${flavour}";
      } // builtins.fromTOML (builtins.readFile catppuccinPallette);
    };
}
