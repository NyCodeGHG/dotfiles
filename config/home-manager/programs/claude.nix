{ pkgs, lib, ... }:
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      permissions.allow = [
        "WebSearch"
        "WebFetch"
        "Bash(nix build:*)"
        "Bash(nix-build:*)"
        "Bash(nix eval:*)"
        "Bash(nix repl:*)"
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
    };
  };
}
