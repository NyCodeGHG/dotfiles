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

      signcolumn = "yes";
      foldenable = false;
    };

    extraPlugins = with pkgs.vimPlugins; [ zen-mode-nvim telescope_hoogle trim-nvim telescope-ui-select-nvim ];
    extraConfigLua = ''
      require('trim').setup({})
    '';

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
        enabledExtensions = [ "hoogle" "ui-select" ];
      };
      which-key.enable = true;
      illuminate = {
        enable = true;

      };
      lualine.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        folding = true;
        indent = true;

        incrementalSelection = {
          enable = true;
          keymaps = {
            initSelection = "<C-Space>";
            nodeIncremental = "<C-Space>";
            nodeDecremental = "<C-B>";
          };
        };

        nixvimInjections = true;
      };

      # Languages
      nix.enable = true;
      crates-nvim.enable = true;
      crates-nvim.extraOptions = {
        src.cmp.enabled = true;
      };

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
            "<leader>ca" = "code_action";
            "<leader>cr" = "rename";
            "<leader>cf" = "format";
          };
        };
        servers = {
          hls = {
            enable = true;
            rootDir = ''require("lspconfig/util").root_pattern(".git")'';
            cmd = [ "haskell-language-server-wrapper" "--lsp" ];
          };
          rust-analyzer.enable = true;
          tsserver.enable = true;
          phpactor.enable = true;
          terraformls.enable = true;
        };
      };
      fidget.enable = true;

      # Completion
      nvim-cmp = {
        enable = true;
        snippet.expand = "luasnip";
        mappingPresets = [ "insert" ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require("luasnip").expand_or_jumpable() then
                  require("luasnip").expand_or_jump()
                else
                  fallback()
                end
              end
            '';
            modes = [
              "i"
              "s"
            ];
          };
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
        };
        preselect = "Item";
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "crates"; }
          { name = "emoji"; }
        ];
        extraOptions.autocomplete = false;
      };
      luasnip.enable = true;
      lspsaga.enable = true;

      neogit.enable = true;
      neorg = {
        enable = true;
        modules = {
          "core.defaults" = {
            __empty = null;
          };
          "core.concealer" = {
            __empty = null;
          };
          "core.dirman" = {
            config = {
              workspaces = {
                home = "~/notes/home";
                work = "~/notes/work";
              };
            };
          };
          "core.completion" = {
            config = {
              engine = "nvim-cmp";
            };
          };
        };
      };
    };

    keymaps = [
      { key = "<C-h>"; action = "<C-w>h"; }
      { key = "<C-j>"; action = "<C-w>j"; }
      { key = "<C-k>"; action = "<C-w>k"; }
      { key = "<C-l>"; action = "<C-w>l"; }
    ];

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
      normal."<leader>cd" = {
        silent = true;
        action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      };
      terminal."<ESC>" = {
        silent = true;
        action = "<C-\\><C-n>";
      };
    };
  };
}
