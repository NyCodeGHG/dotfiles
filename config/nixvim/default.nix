{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.uwumarie) vscode;
  tui = !vscode;
in
{
  imports = [
    ./options.nix
    ./dap.nix
  ];
  colorschemes.oxocarbon.enable = tui;

  globals = {
    mapleader = " ";
    maplocalleader = ",";
  }
  // lib.optionalAttrs tui {
    "conjure#mapping#doc_word" = false;
    "conjure#completion#omnifunc" = false;
    "conjure#highlight#enabled" = true;
    "conjure#filetypes" = [
      "clojure"
      "fennel"
      "lua"
    ];
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
    undofile = true;
    scrolloff = 10;
    sidescrolloff = 10;
    inccommand = "split";
    wrap = false;
    cursorline = true;
  };

  extraPlugins =
    (with pkgs.vimPlugins; [
      vim-nftables
      vim-caddyfile
      vim-glsl
      vim-repeat
      nvim-paredit
      wildfire-nvim
    ])
    ++ lib.optionals tui (
      with pkgs.vimPlugins;
      [
        zen-mode-nvim
        guard-nvim
        vim-jack-in
        vim-dispatch
        vim-dispatch-neovim
        nvim-parinfer
        nvim-vtsls
        jj-nvim
      ]
    );
  extraConfigLuaPre = ''
    require("nvim-paredit").setup()
    require("wildfire").setup({
      keymaps = {
        init_selection = "<C-Space>";
        node_incremental = "<C-Space>";
        node_decremental = "<BS>";
      }
    })
  ''
  + lib.optionalString tui ''

    require("jj").setup({})

    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end
  '';

  extraConfigLua =
    lib.optionalString tui ''
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

    ''
    + ''
      dofile("${./keymaps.lua}")
      dofile("${if vscode then ./keymaps-vscode.lua else ./keymaps-tui.lua}")
    '';

  plugins = {
    # UI
    neo-tree = lib.mkIf tui {
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
    which-key.enable = tui;
    illuminate.enable = tui;
    lualine.enable = tui;
    web-devicons.enable = tui;
    trouble = lib.mkIf tui {
      enable = true;
      settings = {
        picker = {
          actions.__raw = ''require("trouble.sources.snacks").actions'';
        };
      };
    };
    guess-indent.enable = tui;
    highlight-colors.enable = tui;
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

    nvim-autopairs = lib.mkIf tui {
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

    lazydev.enable = tui;

    none-ls = lib.mkIf tui {
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
    snacks = lib.mkIf tui {
      enable = true;
      settings = {
        bigfile.enabled = true;
        picker.enabled = true;
        input.enabled = true;
        win.enabled = false;
      };
    };

    codesettings.enable = tui;

    actions-preview = lib.mkIf tui {
      enable = true;
      settings = {
        backend = "snacks";
      };
    };

    # Treesitter
    treesitter = {
      enable = true;
      folding.enable = tui;
      highlight.enable = tui;
      nixvimInjections = false;
    };

    # Languages
    nix.enable = true;
    crates = lib.mkIf tui {
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
    lsp = lib.mkIf tui {
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
    conjure.enable = tui;
    fidget.enable = tui;
    auto-save.enable = tui;
    blink-cmp = lib.mkIf tui {
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
    luasnip = lib.mkIf tui {
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

  autoGroups = {
    clojure-filetype-indentexpr.clear = true;
  };
}
