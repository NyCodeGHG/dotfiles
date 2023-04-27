{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
    withPython3 = false;
    withNodeJs = false;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      catppuccin-nvim
    ];
    extraLuaConfig = ''
      local o = vim.opt;
      o.relativenumber = true;
      o.expandtab = true;
      o.incsearch = true;
      o.smartindent = true;
      o.smarttab = true;
      vim.cmd("colorscheme catppuccin-mocha");
    '';
    extraPackages = with pkgs; [gcc];
  };
}
