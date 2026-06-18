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
        headers.Authorization = "Bearer \${GITHUB_MCP_PAT}";
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
    };
  };
}
