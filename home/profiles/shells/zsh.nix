{ pkgs, inputs, ... }:
{
  programs.zsh = {
    enable = true;
    # enableVteIntegration = true;
    enableCompletion = true;
    sessionVariables = {
      EDITOR = "nvim";
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
    initExtra = ''
      # use emacs input mode
      bindkey -e
      # ctrl+arrows
      bindkey "\e[1;5C" forward-word
      bindkey "\e[1;5D" backward-word

      # ctrl+delete
      bindkey "\e[3;5~" kill-word

      # ctrl+backspace
      bindkey '^H' backward-kill-word

      # ctrl+shift+delete
      bindkey "\e[3;6~" kill-line
    '';
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];
  };
}
