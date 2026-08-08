{ pkgs, lib, ... }:
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    lspServers = {
      c = {
        command = lib.getExe' pkgs.clang-tools "clangd";
        extensionToLanguage = {
          ".c" = "c";
          ".h" = "c";
          ".cc" = "cpp";
          ".cpp" = "cpp";
          ".hh" = "cpp";
          ".hpp" = "cpp";
        };
      };
      rust = {
        command = lib.getExe pkgs.rust-analyzer;
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
      typescript = {
        command = lib.getExe pkgs.vtsls;
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".mjs" = "javascript";
          ".cjs" = "javascript";
        };
      };
      go = {
        command = lib.getExe pkgs.gopls;
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    };
    context = ''
      # General
      - You are mostly used for quick and dirty prototyping and refining ideas. Do not start implementing things unless you are told.
      - do not commit, push, open pull requests, or trigger any other kind of interaction with other humans unless explicitly asked to
      - if you're unsure about something, ask instead of guessing
      - do things "the right way" instead of quickly hacking together a solution
      - try to use pre-approved tools to avoid unnecessary permission prompts
      - keep changes minimal and focused, don't refactor unless it's required for your task or you're asked to
      - clean up after yourself, e.g. remove temporary files and remove code you just made redundant
      - Do not invent useless backwards compatibility when it's not required
      - Do not hesistate to use manpages. nix-locate-man is installed to look up manpages which are not installed. It is aliased to man.

      # Nix
      - Never search the whole `/nix/store`. Do not run `find`, `fd`, `grep -r`,
        `ls`, or any glob against `/nix/store` itself - it is enormous and the
        scan will hang.
      - Prefer evaluating store paths or building things with nix-build/nix build when required.
        Prefer nix build --no-link to avoid creating symlinks. Only use nix build when required, e.g. nixpkgs has a regular entry point which works with nix-build.
      - Use a shell.nix or devShell in flake.nix when available over quick nix-shell/nix shell invocations.
    '';

    settings = {
      permissions.allow = [
        "WebSearch"
        "WebFetch"
        "Bash(nix build:*)"
        "Bash(nix-build:*)"
        "Bash(nix eval:*)"
        "Bash(nix repl:*)"
        "Bash(nix log:*)"
        "Read(/nix/store/**)"
        "mcp__plugin_claude-code-home-manager_nixos__*"
      ];
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = lib.getExe pkgs.mcp-nixos;
      };
      github = {
        url = "https://api.githubcopilot.com/mcp/";
      };
      linux = {
        command = lib.getExe pkgs.linux-mcp-server;
      };
      victorialogs = {
        command = lib.getExe pkgs.mcp-victorialogs;
        env = {
          VL_INSTANCE_ENTRYPOINT = "https://logs.artemis.marie.cologne";
        };
      };
      grafana = {
        command = lib.getExe pkgs.mcp-grafana;
        env = {
          GRAFANA_URL = "https://grafana.marie.cologne";
          GRAFANA_SERVICE_ACCOUNT_TOKEN.file = "/run/user/1000/agenix/grafana-mcp-token";
        };
      };
      home-assistant = {
        url = "https://hass.marie.cologne/api/mcp";
        oauth = {
          clientId = "http://localhost:12345";
          callbackPort = 12345;
        };
      };
    };
  };

  age.secrets.grafana-mcp-token.file = ../../../secrets/grafana-mcp-token.age;
}
