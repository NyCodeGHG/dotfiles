{ config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    bitwarden
    libsForQt5.ark
    spotify
    element-desktop
    cinny-desktop
    qbittorrent
    mullvad-vpn

    # Programming Languages
    rustup
    gcc
    cmake
    gnumake
    python3

    # Formatters
    stylua
    nixpkgs-fmt

    # Language Servers
    lua-language-server
    nil
    rnix-lsp
    nodePackages.typescript-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
    taplo
    terraform-ls
    nodePackages."@tailwindcss/language-server"
    gopls

    # General Tools
    whois
    file
    dogdns
    handlr
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
    kondo
    terraform
    vscode
    slurp
    grim
    restic
    xdg-utils
    jq
    virt-manager

    tmux
    qemu
    networkmanagerapplet
    wireguard-tools
  ];
}
