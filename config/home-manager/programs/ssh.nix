{ config, lib, pkgs, ... }:
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
      package = pkgs.openssh;
      matchBlocks = {
        "github.com" = {
          user = "git";
          identitiesOnly = true;
          identityFile = config.uwumarie.profiles.ssh.githubKeyFile;
        };
        artemis = {
          hostname = "nue01.marie.cologne";
          identitiesOnly = true;
          identityFile = config.uwumarie.profiles.ssh.defaultKeyFile;
        };
        delphi = {
          hostname = "oci-fra01.marie.cologne";
          identitiesOnly = true;
          identityFile = config.uwumarie.profiles.ssh.defaultKeyFile;
        };
        raspberrypi = {
          user = "pi";
          identityFile = config.uwumarie.profiles.ssh.defaultKeyFile;
          identitiesOnly = true;
        };
        wg-nas = {
          hostname = "10.69.0.8";
          identityFile = config.uwumarie.profiles.ssh.defaultKeyFile;
          identitiesOnly = true;
        };
        gitlabber = {
          hostname = "warpgate.jemand771.net";
          user = "marie:gitlabber";
          identitiesOnly = true;
        };
        "*" = {
          extraOptions = {
            AddKeysToAgent = "yes";
          };
        };
      };
    };
    services.ssh-agent.enable = lib.mkDefault true;
  };
}
