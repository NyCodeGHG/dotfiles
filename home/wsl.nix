{ inputs, ... }:
{
  imports = [
    ./profiles/git.nix
    ./profiles/language-servers/go.nix
    ./profiles/language-servers.nix
    ./profiles/ssh.nix
    ./profiles/direnv.nix
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
    packages = [ inputs.nixpkgs-pgrok.legacyPackages.x86_64-linux.pgrok ];
  };
}