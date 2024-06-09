{ pkgs, lib, config, inputs, ... }:
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
    };
  };
}
