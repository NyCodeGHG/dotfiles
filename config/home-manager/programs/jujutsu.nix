{ pkgs, lib, config, ... }:
lib.mkIf config.uwumarie.profiles.jujutsu
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Marie Ramlow";
        email = "me@nycode.dev";
      };
      ui.diff.tool = [ "${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right" ];
      aliases = {
        gc = [ "git" "clone" "--colocate" ];
        gf = [ "git" "fetch" ];
        f-master = [ "git" "fetch" "--branch=master" "--remote=upstream" ];
        branch = [ "bookmark" ];
        bump = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-" ];
      };
      revsets.log = "trunk() | reachable(@, trunk()..visible_heads())";
    };
  };
}
