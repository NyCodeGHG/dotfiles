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
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      signing.format = null;

      settings = {
        user.email = "marie@marie.cologne";
        user.name = "Marie Ramlow";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        sendemail = {
          confirm = "always";
          suppressCc = "self";
        };
        blame.coloring = "highlightRecent";
        pull.rebase = true;
        merge = {
          conflictstyle = "zdiff3";
          keepbackup = false;
        };
        commit.verbose = true;
        rerere.enabled = true;
        transfer.fsckobjects = true;
        fetch = {
          fsckobjects = true;
          prune = true;
        };
        receive.fsckObjects = true;
        diff = {
          tool = "difft";
          colorMoved = "plain";
          colorMovedWS = "allow-indentation-change";
          context = 10;
          algorithm = "histogram";
          mnemonicPrefix = true;
        };
        log.date = "human";
        column.ui = "auto";
        branch.sort = "-committerdate";
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
