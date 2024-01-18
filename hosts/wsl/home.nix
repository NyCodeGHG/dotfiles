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
  uwumarie.profiles = {
    editors.neovim = true;
    eza = true;
    direnv = true;
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
    zsh = true;
    tmux = true;
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

      nixpkgs-review
    ];
  };
  nix.package = pkgs.nix;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  news.display = "silent";
  programs.zsh.sessionVariables = {
    BROWSER = "wslview";
    SSHX_SERVER = "https://sshx.marie.cologne";
  };
  xdg.configFile."nix-diff-hook".source = diffoscopeWrapper;
}
