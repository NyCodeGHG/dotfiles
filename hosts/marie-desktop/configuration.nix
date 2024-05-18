{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.wsl
    ./vscode.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.11";

  vscode-remote-workaround.enable = true;
  security.polkit.enable = true;

  uwumarie.profiles = {
    users.marie = true;
    nix = true;
  };
  programs.direnv.enable = true;

  wsl = {
    enable = true;
    defaultUser = "marie";
    interop = {
      includePath = false;
      register = true;
    };
    wslConf.user.default = "marie";
    usbip.enable = true;
  };

  networking.hostName = "marie-desktop";

  programs.zsh.enable = true;
  users.users.marie = {
    shell = pkgs.zsh;
    # shell = let
    #     wrapper = pkgs.writeShellScriptBin "shell-wrapper" ''
    #       export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
    #       exec ${pkgs.zsh}/bin/zsh "$@"
    #     '';
    #   in lib.mkForce "${wrapper}/bin/shell-wrapper";
    extraGroups = [ "kvm" ];
  };

  home-manager.users.marie = { config, pkgs, ... }: {
    imports = [ 
     inputs.self.homeManagerModules.config
     ./home
    ];
    home = {
      stateVersion = "23.11";
      username = "marie";
      homeDirectory = "/home/${config.home.username}";
    };
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
  };

  environment.systemPackages = with pkgs; [
    wslu
    # haskellPackages.hoogle
    pgrok
    # language servers
    # haskell-language-server

    android-tools
    fd
    bat
    tokei
    dogdns
    units
    whois

    # cachix

    python3
    rustup
    gcc
    cargo-binutils
    gdb
    qemu
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
    '')
    lazygit
    gitFull

    nixpkgs-review
    nix-output-monitor

    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim
    restic
    wl-clipboard
    kondo
    man-pages man-pages-posix
    p7zip
    jq
    yq
  ];
  environment.shellAliases = {
    "vim" = "nvim";
  };
  virtualisation.podman.enable = true;
  services.postgresql = {

    enable = true;
    ensureUsers = [
      {
        name = "marie";
        ensureClauses = {
          superuser = true;
          login = true;
        };
      }
    ];
  };
  systemd.services.postgresql.wantedBy = lib.mkForce [];
}
