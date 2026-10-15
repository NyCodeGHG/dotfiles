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
        email = "marie@marie.cologne";
      };
      ui = {
        diff-formatter = "difft";
        editor = [
          "nvim"
          "+$line"
        ];
      };
      aliases = {
        /*nixfmt:disable*/
        gc = [ "git" "clone" "--colocate" ];
        gf = [ "git" "fetch" ];
        tug = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-" ];
        roots = [ "log" "-r" "mine() & visible_heads()" ];
        nt = [ "new" "trunk()" ];
        cat = [ "file" "show" ];
        retrunk = [ "rebase" "-o" "trunk()" ];
        open = [ "log" "-r" "open()" ];
        reheat = [ "rebase" "-d" "trunk()" "-s" "all:roots(trunk()..stack(@))" ];
        /*nixfmt:enable*/
      };
      revsets.log = "trunk() | reachable(@, trunk()..visible_heads())";
      revset-aliases = {
        "user(x)" = "author(x) | committer(x)";
        "immutable_heads()" = "present(trunk()) | untracked_remote_bookmarks() | tags()";
        "gh_pages()" = ''ancestors(remote_bookmarks(exact:"gh-pages"))'';

        "stack()" = "stack(@)";
        "stack(x)" = "stack(x, 2)";
        "stack(x, n)" = "ancestors(reachable(x, mutable()), n)";

        "open()" = "stack(mine() | @, 1)";
      };
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
