{ config, lib, ... }:
let
  cfg = config.uwumarie.profiles.git;
in
{
  options.uwumarie.profiles.git = with lib; {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = "Enables the git profile";
    };
    email = mkOption {
      default = "me@nycode.dev";
      type = types.str;
    };
    name = mkOption {
      default = "Marie Ramlow";
      type = types.str;
    };
    signingKey = mkOption {
      default = null;
      type = with types; nullOr str; 
    };
    enableGitHubCLI = mkOption {
      default = true;
      type = types.bool;
      description = "Enables the github cli";
    };
  };
  config = with lib; mkIf cfg.enable {
    programs.git = {
      enable = true;

      userEmail = cfg.email;
      userName = cfg.name;

      extraConfig = mkIf (cfg.signingKey != null) {
        user.signingkey = "${config.home.homeDirectory}/.ssh/${cfg.signingKey}";
        commit.gpgsign = true;
        gpg.format = "ssh";
      };
    };
    programs.gh.enable = cfg.enableGitHubCLI;
  };
}