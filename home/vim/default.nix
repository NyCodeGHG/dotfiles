{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    vimAlias = true;
    package = pkgs.neovim-unwrapped;

    colorschemes.oxocarbon.enable = true;

    globals.mapleader = " ";
    options = {
      # Line Numbers
      number = true;
      relativenumber = true;

      termguicolors = true;

      tabstop = 8;
      shiftwidth = 2;
      expandtab = true;

      laststatus = 3;

      hlsearch = false;
      incsearch = true;
    };

    plugins = {
      # UI
      neo-tree.enable = true;
      telescope = {
        enable = true;
        keymaps = {
          "<leader><space>" = {
            action = "find_files";
            desc = "Find files";
          };
          "<leader>ff" = {
            action = "find_files";
            desc = "Find files";
          };
          "<leader>/" = {
            action = "live_grep";
            desc = "Live grep";
          };
        };
        extensions.fzf-native.enable = true;
      };
      which-key.enable = true;
      illuminate.enable = true;
      lualine.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        # folding = true;
        indent = true;

        nixvimInjections = true;
      };

      # Languages
      nix.enable = true;

      # LSP
      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "K" = "hover";
            "gD" = "references";
            "gd" = "definition";
            "gi" = "implementation";
            "gt" = "type_definition";
          };
        };
        servers = {
          hls.enable = true;
          rust-analyzer.enable = true;
        };
      };
      fidget.enable = true;
    };

    maps = {
      normal."<leader>e" = {
        silent = true;
        action = "<cmd>Neotree toggle<CR>";
        desc = "Toggle Neotree";
      };
      normal."j" = {
        silent = true;
        action = "gj";
      };
      visualOnly."j" = {
        silent = true;
        action = "gj";
      };
      normal."k" = {
        silent = true;
        action = "gk";
      };
      visualOnly."k" = {
        silent = true;
        action = "gk";
      };
    } ;
  };
}
