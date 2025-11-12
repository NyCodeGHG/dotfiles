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
        nt = [
          "new"
          "trunk()"
        ];
        cat = [
          "file"
          "show"
        ];
      };
      revsets.log = "trunk() | reachable(@, trunk()..visible_heads())";
      fsmonitor.backend = "watchman";
      fsmonitor.watchman.register-snapshot-trigger = true;
      templates = {
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };
  };
  home.packages = with pkgs; [
    watchman
    difftastic
    mergiraf
  ];
}
