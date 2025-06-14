{
  pkgs,
  config,
  lib,
  ...
}:
let
  theme = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "minimal";
    version = "unstable-2023-12-26";
    src = pkgs.fetchFromGitHub {
      owner = "niksingh710";
      repo = "minimal-tmux-status";
      rev = "3ee70b29af2ba6ac90c84ba7200da1d75b16bcf3";
      hash = "sha256-E6eGK2PXouqJY4E8ze3+HzFm/W5Os22bRiKyhdLDVKg=";
    };
  };
in
{
  options.uwumarie.profiles.tmux = lib.mkEnableOption "tmux profile";
  config = lib.mkIf config.uwumarie.profiles.tmux {
    programs.tmux = {
      enable = true;
      clock24 = true;
      escapeTime = 50;
      terminal = "screen-256color";
      plugins = [ theme ];
    };
  };
}
