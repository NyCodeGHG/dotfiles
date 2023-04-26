{
  config,
  lib,
  pkgs,
  ...
}: let
  fromYAML = f: let
    jsonFile =
      pkgs.runCommand "in.json"
      {
        nativeBuildInputs = [pkgs.jc];
      } ''
        jc --yaml < "${f}" > "$out"
      '';
  in
    builtins.elemAt (builtins.fromJSON (builtins.readFile jsonFile)) 0;
in {
  programs.lazygit = {
    enable = true;
    settings =
      {
        gui = {
          showIcons = true;
        };
      }
      // fromYAML (pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "lazygit";
          rev = "c98d9851191fb4c1c31da2fad054210351c65a27";
          sha256 = "190iig4vfh649clwy0p2aw3nji44w151zppkr6rb07if5xs8542n";
        }
        + "/themes/mocha.yml");
  };
}
