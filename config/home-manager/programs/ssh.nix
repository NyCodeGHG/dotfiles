{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uwumarie.profiles.ssh = {
    enable = lib.mkEnableOption (lib.mdDoc "ssh config");
    githubKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/github.ed25519";
    };
    defaultKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/default.ed25519";
    };
  };
  config = lib.mkIf config.uwumarie.profiles.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      package = pkgs.openssh;
      settings = {
        "*" = {
          AddKeysToAgent = true;
        };
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentitiesOnly = true;
          IdentityFile = config.uwumarie.profiles.ssh.githubKeyFile;
        };
        artemis = {
          HostName = "artemis.marie.cologne";
          IdentitiesOnly = true;
          IdentityFile = config.uwumarie.profiles.ssh.defaultKeyFile;
        };
        delphi = {
          HostName = "delphi.marie.cologne";
          IdentitiesOnly = true;
          IdentityFile = config.uwumarie.profiles.ssh.defaultKeyFile;
        };
        wiiu = {
          HostName = "192.168.1.62";
          IdentitiesOnly = true;
        };
      };
    };
  };
}
