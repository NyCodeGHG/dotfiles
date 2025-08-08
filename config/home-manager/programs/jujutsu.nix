{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.uwumarie.profiles.jujutsu {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Marie Ramlow";
        email = "me@nycode.dev";
      };
      ui.diff-formatter = [
        "${pkgs.difftastic}/bin/difft"
        "--color=always"
        "$left"
        "$right"
      ];
      aliases = {
        gc = [
          "git"
          "clone"
          "--colocate"
        ];
        gf = [
          "git"
          "fetch"
        ];
        f-master = [
          "git"
          "fetch"
          "--branch=master"
          "--remote=upstream"
        ];
        bump = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & bookmarks())"
          "--to"
          "@-"
        ];
        roots = [
          "log"
          "-r"
          "mine() & visible_heads()"
        ];
      };
      revsets.log = "trunk() | reachable(@, trunk()..visible_heads())";
      fsmonitor.backend = "watchman";
      fsmonitor.watchman.register-snapshot-trigger = true;
    };
  };
  home.packages = with pkgs; [
    watchman
    difftastic
    mergiraf
  ];
}
