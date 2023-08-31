{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    plugins = [
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
      }
    ];
  };
}
