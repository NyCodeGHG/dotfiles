{ pkgs, ... }:
{
  config = {
    # colorschemes.oxocarbon.enable = true;
    # colorschemes.melange.enable = true;
    colorschemes.kanagawa = {
      enable = true;
      settings = {
        background.dark = "dragon";
      };
    };
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
      vim-glsl
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
            options.desc = "Find files";
          };
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find files";
          };
          "<leader>/" = {
            action = "live_grep";
            options.desc = "Live grep";
          };
        };
        extensions.fzf-native.enable = true;
        enabledExtensions = [ "hoogle" "ui-select" ];
      };
      which-key.enable = true;
      illuminate.enable = true;
      lualine.enable = true;
      web-devicons.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        folding = true;
        settings = {
          indent.enable = false;
          highlight.enable = true;
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-Space>";
              node_incremental = "<C-Space>";
              node_decremental = "<C-B>";
            };
          };
        };
        nixvimInjections = true;
      };

      # Languages
      nix.enable = true;
      crates-nvim.enable = true;
      crates-nvim.extraOptions = {
        completion.cmp.enabled = true;
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
            "<leader>cf" = "format";
          };
        };
        servers = {
          hls = {
            enable = true;
            rootDir = ''require("lspconfig/util").root_pattern(".git")'';
            installGhc = false;
          };
          rust_analyzer = {
            enable = true;
            installRustc = false;
            installCargo = false;
            settings.diagnostics.enable = true;
          };
          ts_ls.enable = true;
          denols.enable = true;
          # phpactor.enable = true;
          terraformls.enable = true;
          gopls.enable = true;
          lua_ls.enable = true;
          pylsp.enable = true;
          svelte.enable = true;
          # nixd.enable = true;
          nil_ls.enable = true;
          gleam.enable = true;
          jsonls.enable = true;
          clangd.enable = true;
          cssls.enable = true;
        };
      };
      fidget.enable = true;

      # Completion
      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          mappingPresets = [ "insert" ];
          mapping = {
            __raw = ''
              cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
              })
            '';
          };
          preselect = "cmp.PreselectMode.None";
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

      leap.enable = true;
    };

    keymaps = [
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.silent = true; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.silent = true; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.silent = true; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.silent = true; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<cr>"; options = { desc = "Toggle Neotree"; silent = true; }; }
      { mode = [ "n" "v" ]; key = "j"; action = "gj"; options.silent = true; }
      { mode = [ "n" "v" ]; key = "k"; action = "gk"; options.silent = true; }
      { mode = [ "n" "v" ]; key = "<leader>cd"; options.silent = true; action.__raw = "vim.diagnostic.open_float"; }
      { mode = "t"; options.silent = true; key = "<ESC>"; action = "<C-\\><C-n>"; }
      { mode = "n"; options.silent = true; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; }
      { mode = "n"; options.silent = true; key = "<leader>t"; action = "<cmd>terminal<cr>"; }
      { mode = "n"; options.silent = true; key = "<leader>cr"; action = "<cmd>Lspsaga rename<cr>"; }
      { mode = "n"; options.silent = true; key = "<leader>ca"; action = "<cmd>Lspsaga code_action<cr>"; }
    ];

    highlight = {
      "@text.diff.add.diff" = { fg = "#04b539"; };
      "@text.diff.delete.diff" = { fg = "#e30202"; };
    };
  };
}
