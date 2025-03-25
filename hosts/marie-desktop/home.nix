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
  programs.zoxide.enable = true;

  uwumarie.profiles.ssh = {
    enable = true;
    defaultIdentityFile = "~/.ssh/id_ed25519";
    hosts = {
      "github.com".user = "git";
      artemis.hostname = "artemis.marie.cologne";
      delphi.hostname = "delphi.marie.cologne";
      raspi = {
        user = "pi";
        hostname = "raspberrypi.fritz.box";
      };
      wg-nas.hostname = "192.168.178.30";
      gitlabber-public = {
        hostname = "warpgate.jemand771.net";
        user = "marie:gitlabber";
      };
      gitlabber.hostname = "gitlabber.weasel-gentoo.ts.net";
    };
  };
}
