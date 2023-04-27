{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    dotDir = ".config/zsh";
    history.path = "${config.home.homeDirectory}/.local/share/zsh/.zsh_history";
    shellAliases = {
      lg = "lazygit";
      cat = "bat $@";
      dig = "dog $@";
      neofetch = "neowofetch";
    };
    # Enjoy the Terminal Silence
    initExtra = ''
      unsetopt BEEP
    '';

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "catppuccin-zsh-syntax-hightlighting";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "zsh-syntax-highlighting";
          rev = "06d519c20798f0ebe275fc3a8101841faaeee8ea";
          sha256 = "1yj916klvzpvwghii7m6qx2ya3p2kx25nydymilvjzbx8z0sdcj3";
        };
        file = "themes/catppuccin_mocha-zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
      }
    ];
  };
}
