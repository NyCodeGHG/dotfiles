{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types;
  inherit (config.uwumarie.profiles.ssh)
    defaultIdentityFile
    hosts;
in
{
  options.uwumarie.profiles.ssh = {
    enable = mkEnableOption "ssh config";
    defaultIdentityFile = mkOption {
      type = types.str;
    };
    hosts = mkOption {
      type = with types; attrsOf (submodule ({ config, name, ... }: {
        options = {
          match = mkOption {
            type = types.str;
            default = name;
          };
          hostname = mkOption {
            type = types.str;
            default = config.match;
          };
          user = mkOption {
            type = with types; nullOr str;
          };
          identitiesOnly = mkOption {
            type = types.bool;
            default = true;
          };
          identityFile = mkOption {
            type = types.str;
            default = defaultIdentityFile;
          };
        };
      }));
    };
  };
  config = lib.mkIf config.uwumarie.profiles.ssh.enable {
    services.ssh-agent.enable = lib.mkDefault true;
    programs.ssh = {
      enable = true;
      package = pkgs.openssh;
      matchBlocks = lib.mapAttrs' (_: value: lib.nameValuePair value.match value) hosts;
    };
  };
}
