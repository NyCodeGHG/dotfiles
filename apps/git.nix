{ config
, pkgs
, ...
}: {
  programs.git = {
    enable = true;

    userEmail = "me@nycode.dev";
    userName = "Marie Ramlow";

    signing = {
      key = "/home/marie/.ssh/github_laptop.ed25519";
      signByDefault = true;
    };

    extraConfig = {
      gpg = { format = "ssh"; };

      url = {
        "ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
      };

      init = { defaultBranch = "main"; };
      commit = { gpgsign = true; };
      tag = { gpgsign = true; };
    };
  };
}
