{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uwumarie.profiles.ssh.enable = lib.mkEnableOption (lib.mdDoc "ssh config");
  config = lib.mkIf config.uwumarie.profiles.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      package = pkgs.openssh;
      settings = {
        "*" = {
          AddKeysToAgent = true;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "10m";
        };
        "github.com" = {
          User = "git";
          IdentitiesOnly = true;
        };
        artemis = {
          HostName = "artemis.marie.cologne";
          IdentitiesOnly = true;
        };
        delphi = {
          HostName = "delphi.marie.cologne";
          IdentitiesOnly = true;
        };
        wiiu = {
          HostName = "192.168.1.62";
          IdentitiesOnly = true;
        };
        gitlabber = {
          User = "root";
          IdentitiesOnly = true;
        };
        "opus opusshgw" = {
          User = "root";
          HostName = "opusshgw";
        };
      };
    };
  };
}
