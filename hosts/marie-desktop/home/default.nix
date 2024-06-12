{ config, inputs, pkgs, ... }:
let
  diffoscopeWrapper = pkgs.writeScript "diffoscope-wrapper"
    ''
              #! ${pkgs.stdenv.shell}
      	exec >&2
      	echo ""
              echo "non-determinism detected in $2; diff with previous round follows:"
              echo ""
              time ${pkgs.utillinux}/bin/runuser -u diffoscope -- ${pkgs.diffoscope}/bin/diffoscope "$1" "$2"
              exit 0
    '';
in
{
  imports = [
    ./ssh-forward.nix
  ];
  uwumarie.profiles = {
    eza = true;
    git = {
      enable = true;
      signingKey = "github.ed25519";
      enableGitEmail = true;
    };
    jujutsu = true;
    ripgrep = true;
    ssh = true;
    starship = true;
    unlock-ssh-keys = true;
    fish = true;
    tmux = true;
  };
  # locale workaround
  programs.home-manager.enable = true;
  programs.zoxide.enable = true;
  news.display = "silent";
  xdg.configFile."nix-diff-hook".source = diffoscopeWrapper;
}
