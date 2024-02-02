{ pkgs, options, config, lib, inputs, ... }:
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
    signingKey = mkOption {
      default = null;
      type = with types; nullOr str;
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
  config = with lib; mkIf cfg.enable {
    programs.git = {
      enable = true;

      userEmail = "me@nycode.dev";
      userName = "Marie Ramlow";

      package = pkgs.gitFull;

      extraConfig = mkMerge [
        (mkIf (cfg.signingKey != null) {
          user.signingkey = "${config.home.homeDirectory}/.ssh/${cfg.signingKey}";
          commit.gpgsign = true;
        })
        {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          gpg.format = "ssh";
          gpg.ssh.allowedSignersFile = "${pkgs.writeText "allowed-signers" ''
            toto.rei0210@gmail.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDO7viRSZdRJbLIOgx6PU8+qlmUys2dKbmhiJL4XcYmnAUoASt3T6E7WwSQowNTufjtr0aa3wDg7vJpphccPjCC+PmwR6covZV/pd7Kr4zfRBTOAwgzh86fpnwUE2s8BGQQgfx1Pklbo+Dd1A5TyvkXVntYN7cX0Fw0bnbH5qMOntdwwLF5fix2vGBOL50udqPhriQAv03n3WQiC/gS+v/2ooi258VI3PBqBvJSTjPjEAIsRfbILZKO5Xy7I0hC0rdCADHRI+FVxqWsnJpAqjAudpgh4n68fX6ye7+JcN9tdqfQIQ+lq1FkatTi0pbMUd4q1qBYpzI8bspVreoICNDl1zKN9akif+BakdfH21VXC3w6uBIGDLKqY7eULSQFADgVOctSZjGYg73Vaqf+28EcfsKg5r3ALqgm1BsTweeHWTo1CflMno08quMZtzpNpa7odmV2EW3bCsjVcgkHfYw9RIFVPiomExA9Pupx6AGCwFoXFFPTD/LEvBmgcGyiyEyXugLkdfHlqlnclyjgZwqVGdY5bHrt6RUiT2xZ5Dzgx193sx+Ion4aMTZx5yuvzqIK5u5b9mfCX5NdYuxQc5fb8h/YyqFstjBnuP50VBpKXJJj8lPrFYKao0QewVJfFFEF8/hlv19mYcwvOXP5eN+e/KbFYhwRpSZFYt97VwkdHQ==
            me@nycode.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIdeDXldzVPq9QIYsm5XBZEWFhyY4LBCjp+/dEMfyvbf
            me@nycode.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz
          ''}";
        }
      ];
      includes = mkIf cfg.enableGitEmail ([
        {
          # hardcode path because git can't expand $XDG_RUNTIME_DIR
          path = "/run/user/1000/agenix/git-email";
        }
      ]);
      lfs.enable = true;
    };
    programs.gh.enable = cfg.enableGitHubCLI;
    age.secrets.git-email = mkIf cfg.enableGitEmail {
      file = "${inputs.self}/secrets/git-email.age";
    };
    age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
  };
}
