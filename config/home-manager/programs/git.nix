{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
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
    enableGitHubCLI = mkOption {
      default = true;
      type = types.bool;
      description = "Enables the github cli";
    };
    enableGitEmail = mkOption {
      default = false;
      type = types.bool;
      description = "Configures git for email usage";
    };
  };
  config =
    lib.mkIf cfg.enable {
      programs.git = {
        enable = true;

        settings = {
          user.email = "me@nycode.dev";
          user.name = "Marie Ramlow";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          sendemail = {
            confirm = "always";
            suppressCc = "self";
          };
        };

        package = pkgs.gitFull;

        includes = lib.mkIf cfg.enableGitEmail [
          {
            # hardcode path because git can't expand $XDG_RUNTIME_DIR
            path = "/run/user/1000/agenix/git-email";
          }
        ];
        lfs.enable = true;
        ignores = [
          "*~"
          "*.swp"
          "*.qcow2"
        ];
      };
      programs.gh.enable = cfg.enableGitHubCLI;
      age.secrets.git-email = lib.mkIf cfg.enableGitEmail {
        file = "${inputs.self}/secrets/git-email.age";
      };
    };
}
