{ pkgs, lib, ... }:
{
  imports = [
    ./dap.nix
  ];
  colorschemes.oxocarbon.enable = true;
  # colorschemes.melange.enable = true;
  # colorschemes.kanagawa = {
  #   enable = true;
  #   settings = {
  #     background.dark = "dragon";
  #   };
  # };

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

    tabstop = 4;
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
    guard-nvim
    vim-nftables
    vim-caddyfile
    vim-glsl
    vim-repeat
    vim-jack-in
    vim-dispatch
    vim-dispatch-neovim
    nvim-paredit
    nvim-parinfer
    wildfire-nvim
    nvim-vtsls
    jj-nvim
  ];
  extraConfigLuaPre = ''
    require("nvim-paredit").setup()
    require("wildfire").setup({
      keymaps = {
        init_selection = "<C-Space>";
        node_incremental = "<C-Space>";
        node_decremental = "<BS>";
      }
    })

    require("jj").setup({})

    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end
  '';

  extraConfigLua = ''
    local autopairs = require('nvim-autopairs')
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    for _, rule in ipairs(autopairs.get_rules("'")) do
      rule.not_filetypes = rule.not_filetypes or {}
      table.insert(rule.not_filetypes, "clojure")
    end

    autopairs.add_rules({
      Rule('"', '"', "clojure")
        :with_pair(cond.not_after_text('"')),
    })

    dofile("${./keymaps.lua}")
  '';

  plugins = {
    # UI
    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file.enabled = true;
        };
        event_handlers.__raw = ''
          {
            { event = require("neo-tree.events").FILE_MOVED, handler = on_move },
            { event = require("neo-tree.events").FILE_RENAMED, handler = on_move },
          }
        '';
      };
    };
    which-key.enable = true;
    illuminate.enable = true;
    lualine.enable = true;
    web-devicons.enable = true;
    trouble = {
      enable = true;
      settings = {
        picker = {
          actions.__raw = ''require("trouble.sources.snacks").actions'';
        };
      };
    };
    guess-indent.enable = true;
    highlight-colors.enable = true;
    # hmts.enable = true;

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

    nvim-autopairs = {
      enable = true;
      settings = {
        disable_filetype = [
          "TelescopePrompt"
          "spectre_panel"
          "snacks_picker_input"
        ];
        check_ts = true;
        ts_config = {
          clojure = [
            "str_lit"
            "comment"
          ];
        };
      };
    };

    lazydev.enable = true;

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
        picker.enabled = true;
        input.enabled = true;
      };
    };

    codesettings.enable = true;

    actions-preview = {
      enable = true;
      settings = {
        backend = "snacks";
      };
    };

    # Treesitter
    treesitter = {
      enable = true;
      folding.enable = true;
      highlight.enable = true;
      nixvimInjections = false;
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
      servers = {
        hls = {
          # enable = true;
          installGhc = false;
        };
        rust_analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
          settings.diagnostics.enable = true;
        };
        vtsls = {
          enable = true;
          settings.vtsls = {
            autoUseWorkspaceTsdk = true;
          };
        };
        # denols.enable = true;
        # phpactor.enable = true;
        terraformls.enable = true;
        gopls.enable = true;
        lua_ls.enable = true;
        ty.enable = true;
        svelte.enable = true;
        nixd.enable = true;
        # nil_ls.enable = true;
        gleam.enable = false;
        jsonls.enable = true;
        clangd.enable = true;
        cssls.enable = true;
        clojure_lsp.enable = true;

        emmet_language_server.enable = true;
        biome = {
          enable = true;
          packageFallback = true;
        };
        qmlls.enable = true;
      };
    };
    conjure.enable = true;
    fidget.enable = true;
    auto-save.enable = true;
    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "super-tab";
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
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
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
      };
    };
    leap.enable = true;
  };

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

  autoCmd = [
    {
      event = "FileType";
      pattern = "clojure";
      group = "clojure-filetype-indentexpr";
      callback = {
        __raw = ''
          function()
            vim.bo.indentexpr = ""
            vim.bo.smartindent = false
            vim.bo.autoindent = true
            vim.bo.lisp = true
          end
        '';
      };
    }
  ];

  autoGroups.clojure-filetype-indentexpr.clear = true;
}
