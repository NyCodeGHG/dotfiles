{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim ];
  news.display = "silent";
  uwumarie.profiles = {
    eza = true;
    git = {
      enable = true;
      # signingKey = "id_ed25519";
      signingKey = null;
      enableGitEmail = false;
    };
    jujutsu = true;
    ripgrep = true;
    ssh = {
      enable = true;
      githubKeyFile = "~/.ssh/id_ed25519";
      defaultKeyFile = "~/.ssh/id_ed25519";
    };
    fish = true;
    tmux = true;
  };
}
