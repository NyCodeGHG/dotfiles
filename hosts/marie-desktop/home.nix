{ config, inputs, pkgs, ... }:
{
  imports = [
    ../../modules/hm/switch-to-windows.nix
  ];
  home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim ];
  news.display = "silent";
  uwumarie.profiles = {
    eza = true;
    git = {
      enable = true;
      # signingKey = "id_ed25519";
      signingKey = null;
      enableGitEmail = true;
    };
    jujutsu = true;
    ssh = {
      enable = true;
      githubKeyFile = "~/.ssh/id_ed25519";
      defaultKeyFile = "~/.ssh/id_ed25519";
    };
    fish = true;
    tmux = true;
  };
  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/agenix.ed25519"
  ];
  programs.switch-to-windows.enable = true;

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      sync_address = "https://atuin.marie.cologne";
      sync.records = true;
    };
  };
}
