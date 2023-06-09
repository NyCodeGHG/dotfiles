{ config
, pkgs
, lib
, ...
}:
let
  whenSSHKeyExists = lib.mkIf config.uwumarie.sshKey != null;
in
{
  programs.git = {
    enable = true;

    userEmail = "me@nycode.dev";
    userName = "Marie Ramlow";

    # signing = whenSSHKeyExists {
    #   key = "/home/marie/.ssh/${config.uwumarie.sshKey}";
    #   signByDefault = true;
    # };

    # extraConfig = {
    #   gpg = whenSSHKeyExists { format = "ssh"; };
    #   init = { defaultBranch = "main"; };
    #   commit = whenSSHKeyExists { gpgsign = true; };
    #   tag = whenSSHKeyExists { gpgsign = true; };
    # };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = if config.uwumarie.sshKey != null then "ssh" else "https";
    };
  };
}
