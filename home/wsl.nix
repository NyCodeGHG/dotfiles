{ self, pkgs, ... }:
{
  imports = [
    ./profiles/git.nix
    ./profiles/language-servers/go.nix
    ./profiles/language-servers/nix.nix
    ./profiles/language-servers/haskell.nix
    ./profiles/language-servers.nix
    ./profiles/ssh.nix
    ./profiles/direnv.nix
    ./profiles/tools
    ./profiles/shells/zsh.nix
    ./profiles/shells/starship.nix
    ./profiles/vim.nix
    ./profiles/languages.nix
  ];
  uwumarie.profiles.git = {
    enable = true;
    signingKey = "github.ed25519";
  };
  programs.home-manager.enable = true;
  home = {
    stateVersion = "23.11";
    username = "marie";
    homeDirectory = "/home/marie";
    packages = with pkgs; [ wslu locale glibcLocales haskellPackages.hoogle tea pgrok ];
  };
  nix.package = pkgs.nix;
  nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
}
