{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
