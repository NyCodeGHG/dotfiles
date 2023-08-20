{ pkgs
, config
, lib
, ...
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
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
    ];
  };
}
