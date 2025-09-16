{ config, lib, pkgs, ... }:
{
  options.uwumarie.profiles.tools = lib.mkEnableOption "tools";
  config = lib.mkIf config.uwumarie.profiles.tools {
    environment.systemPackages = with pkgs; [
      rust-analyzer
      nixfmt
      gopls
      vscode-langservers-extracted
      python3
      python3Packages.editorconfig
      clojure-lsp
      nixd
    ];
  };
}
