{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
