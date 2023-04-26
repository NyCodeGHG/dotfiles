{ pkgs, config, lib, ...}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
    withPython3 = false;
    withNodeJs = false;
  };
}
