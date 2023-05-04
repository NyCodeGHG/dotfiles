{ config
, pkgs
, inputs
, ...
}: {
  home.packages = with pkgs; [
    bitwarden
    libsForQt5.ark
    spotify

    # Programming Languages
    rustup
    gcc
    cmake
    gnumake

    # Formatters
    stylua
    nixpkgs-fmt

    # Language Servers
    lua-language-server
    nil
    rnix-lsp
    rust-analyzer
    nodePackages.typescript-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
    taplo

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
    xdg-user-dirs
    magic-wormhole
    steamcmd
    steam-run
    pulseaudio
    pipewire
    wireplumber

    tmux
  ];
}
