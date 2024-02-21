{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.wsl
  ];

  uwumarie.profiles = {
    users.marie = true;
    nix = true;
  };

  wsl.enable = true;
  wsl.defaultUser = "marie";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.11";

  home-manager.users.marie = { config, pkgs, ... }: {
    imports = [ 
     inputs.self.homeManagerModules.config
     ./home.nix
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
    haskellPackages.hoogle
    tea
    pgrok
    # language servers
    haskell-language-server
    gopls
    lua-language-server
    nil

    android-tools
    fd
    bat
    tokei
    dogdns
    units

    cachix

    rustup
    cargo-binutils
    gdb
    qemu
    lazygit
    gitFull

    nixpkgs-review
    nix-output-monitor
  ];
}
