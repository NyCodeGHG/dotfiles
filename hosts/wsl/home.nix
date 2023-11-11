{ config, inputs, pkgs, ... }:
{
  uwumarie.profiles = {
    editors.neovim = true;
    eza = true;
    direnv = true;
    git = {
      enable = true;
      signingKey = "github.ed25519";
    };
    jujutsu = true;
    ripgrep = true;
    ssh = true;
    starship = true;
    unlock-ssh-keys = true;
    zsh = true;
  };
  programs.home-manager.enable = true;
  home = {
    stateVersion = "23.05";
    username = "marie";
    homeDirectory = "/home/${config.home.username}";
    packages = with pkgs; [
      wslu
      haskellPackages.hoogle
      tea
      pgrok
      # language servers
      haskell-language-server
      gopls
      lua-language-server
      nil
      jetbrains.idea-community
      android-tools
    ];
  };
  nix.package = pkgs.nix;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  news.display = "silent";
  programs.zsh.sessionVariables.BROWSER = "wslview";
}
