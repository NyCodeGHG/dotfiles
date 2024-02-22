{ pkgs, lib, config, inputs, ... }:
lib.mkIf config.uwumarie.profiles.jujutsu
{
  programs.jujutsu = {
    enable = true;
    enableZshIntegration = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.system}.jujutsu;
    settings = {
      user = {
        name = "Marie Ramlow";
        email = "me@nycode.dev";
      };
      ui.diff.tool = [ "${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right" ];
    };
  };
}
