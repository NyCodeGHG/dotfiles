{ pkgs, ... }:
{
  config = {
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

    extraPlugins = with pkgs.vimPlugins; [
      zen-mode-nvim 
      telescope_hoogle 
      telescope-ui-select-nvim 
      guard-nvim 
      neoconf-nvim 
      vim-nftables 
      vim-caddyfile
    ];
    extraConfigLuaPre = ''
      require("neoconf").setup()
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
          # hls = {
          #   enable = true;
          #   rootDir = ''require("lspconfig/util").root_pattern(".git")'';
          # };
          rust-analyzer = {
            enable = true;
            installRustc = false;
            installCargo = false;
          };
          tsserver.enable = true;
          phpactor.enable = true;
          terraformls.enable = true;
          gopls.enable = true;
          lua-ls.enable = true;
          pylsp.enable = true;
          svelte.enable = true;
        };
      };
      fidget.enable = true;

      # Completion
      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          snippet.expand = "luasnip";
          mappingPresets = [ "insert" ];
          mappings = {
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
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.silent = true; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.silent = true; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.silent = true; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.silent = true; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<cr>"; options = { desc = "Toggle Neotree"; silent = true; }; }
      { mode = [ "n" "v" ]; key = "j"; action = "gj"; options.silent = true; }
      { mode = [ "n" "v" ]; key = "k"; action = "gk"; options.silent = true; }
      { mode = [ "n" "v" ]; key = "<leader>cd"; options.silent = true; action = "vim.diagnostic.open_float"; lua = true; }
      { mode = "t"; options.silent = true; key = "<ESC>"; action = "<C-\\><C-n>"; }
      { mode = "n"; options.silent = true; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; }
      { mode = "n"; options.silent = true; key = "<leader>t"; action = "<cmd>terminal<cr>"; }
    ];

    highlight = {
      "@text.diff.add.diff" = { fg = "#04b539"; };
      "@text.diff.delete.diff" = { fg = "#e30202"; };
    };
  };
}
