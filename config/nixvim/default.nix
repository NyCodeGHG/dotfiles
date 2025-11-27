{ pkgs, lib, ... }:
{
  imports = [
    ./dap.nix
  ];
  # colorschemes.oxocarbon.enable = true;
  # colorschemes.melange.enable = true;
  colorschemes.kanagawa = {
    enable = true;
    settings = {
      background.dark = "dragon";
    };
  };

  globals = {
    mapleader = " ";
    maplocalleader = ",";
    "conjure#mapping#doc_word" = false;
    "conjure#completion#omnifunc" = false;
    "conjure#highlight#enabled" = true;
  };
  opts = {
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
    vim-repeat
    vim-jack-in
    vim-dispatch
    vim-dispatch-neovim
    nvim-paredit
  ];
  extraConfigLuaPre = ''
    require("neoconf").setup()
    require("nvim-paredit").setup()
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
        "<leader>fr" = {
          action = "resume";
          options.desc = "Resume search";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Find buffers";
        };
        "<leader>fm" = {
          action = "man_pages";
          options.desc = "Find man pages";
        };
        "<leader>fz" = {
          action = "current_buffer_fuzzy_find";
          options.desc = "Fuzzy search in buffer";
        };
      };
      extensions.fzf-native.enable = true;
    };
    which-key.enable = true;
    illuminate.enable = true;
    lualine.enable = true;
    web-devicons.enable = true;
    trouble.enable = true;
    guess-indent.enable = true;
    highlight-colors.enable = true;
    hmts.enable = true;

    mini-surround = {
      enable = true;
      settings = {
        mappings = {
          add = "gza";
          delete = "gzd";
          find = "gzf";
          find_left = "gzF";
          highlight = "gzh";
          replace = "gzr";
          update_n_lines = "gzn";
        };
      };
    };

    lazydev.enable = true;

    lsp-format.enable = true;
    none-ls = {
      enable = true;
      sources = {
        formatting = {
          sqruff.enable = true;
          typstyle.enable = true;
        };
        diagnostics = {
          sqruff.enable = true;
        };
      };
    };
    snacks = {
      enable = true;
      settings = {
        bigfile.enabled = true;
      };
    };

    auto-session.enable = true;

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
    crates = {
      enable = true;
      settings = {
        lsp = {
          enabled = true;
          actions = true;
          completion = true;
          hover = true;
        };
        completion.crates = {
          enabled = true;
          max_results = 8;
          min_chars = 3;
        };
      };
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
          installGhc = false;
        };
        rust_analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
          settings.diagnostics.enable = true;
        };
        ts_ls.enable = true;
        # denols.enable = true;
        # phpactor.enable = true;
        terraformls.enable = true;
        gopls.enable = true;
        lua_ls.enable = true;
        pylsp.enable = true;
        svelte.enable = true;
        nixd.enable = true;
        # nil_ls.enable = true;
        gleam.enable = false;
        jsonls.enable = true;
        clangd.enable = true;
        cssls.enable = true;
        clojure_lsp.enable = true;
      };
    };
    conjure.enable = true;
    fidget.enable = true;
    auto-save.enable = true;
    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "enter";
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        blink-cmp.settings = {
          sources.providers = {
            lazydev = {
              name = "LazyDev";
              module = "lazydev.integrations.blink";
              # make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100;
            };
          };
        };
      };
    };
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
      };
    };
    lspsaga.enable = true;
    leap.enable = true;
  };

  keymaps = [
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<cr>";
      options = {
        desc = "Toggle Neotree";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "j";
      action = "gj";
      options.silent = true;
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "k";
      action = "gk";
      options.silent = true;
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cd";
      options.silent = true;
      action.__raw = "vim.diagnostic.open_float";
    }
    {
      mode = "t";
      options.silent = true;
      key = "<ESC>";
      action = "<C-\\><C-n>";
    }
    {
      mode = "n";
      options.silent = true;
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<cr>";
    }
    {
      mode = "n";
      options.silent = true;
      key = "<leader>t";
      action = "<cmd>terminal<cr>";
    }
    {
      mode = "n";
      options.silent = true;
      key = "<leader>cr";
      action = "<cmd>Lspsaga rename<cr>";
    }
    {
      mode = "n";
      options.silent = true;
      key = "<leader>ca";
      action = "<cmd>Lspsaga code_action<cr>";
    }
    {
      mode = "i";
      options.silent = true;
      key = "<C-k>";
      action.__raw = "function() require('luasnip').expand() end";
    }
    {
      mode = "i";
      options.silent = true;
      key = "<C-j>";
      action.__raw = "function() require('luasnip').jump(1) end";
    }
    {
      mode = "i";
      options.silent = true;
      key = "<C-l>";
      action.__raw = "function() require('luasnip').jump(-1) end";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      options.silent = true;
      key = "s";
      action = "<Plug>(leap)";
    }
    {
      mode = "n";
      options.silent = true;
      key = "S";
      action = "<Plug>(leap-from-window)";
    }
  ];

  highlight = {
    "@text.diff.add.diff" = {
      fg = "#04b539";
    };
    "@text.diff.delete.diff" = {
      fg = "#e30202";
    };
  };

  diagnostic.settings = {
    virtual_lines = false;
    virtual_text = true;
  };

}
