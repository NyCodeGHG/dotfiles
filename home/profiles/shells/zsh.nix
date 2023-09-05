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
        name = "zsh-autocomplete";
        file = "zsh-autocomplete.plugin.zsh";
        src = "${pkgs.zsh-autocomplete}/share/zsh-autocomplete";
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];
  };
}
