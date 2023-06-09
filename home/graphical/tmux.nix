{ pkgs
, config
, lib
, ...
}:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = true;
    clock24 = true;
    terminal = "screen-256color";
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color*:RGB"
      set -sg escape-time 0
    '';
  };
}
