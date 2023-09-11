{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    enableCompletion = false;
    initExtra = ''
      # use emacs input mode
      bindkey -e
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
