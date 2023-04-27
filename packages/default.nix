{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    bitwarden
    libsForQt5.ark

    # Programming Languages
    rustup
    gcc

    # Formatters
    stylua

    # Language Servers
    lua-language-server
    nil
    rust-analyzer
    nodePackages.typescript-language-server
    nodePackages.vscode-json-languageserver

    # General Tools
    whois
    file
    dogdns
    xdg-utils
    brightnessctl
    wl-clipboard
    ripgrep
    just
    update-nix-fetchgit
    asciinema
  ];
}
