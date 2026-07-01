{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.uwumarie.profiles.ssh-agent = lib.mkEnableOption (lib.mdDoc "System wide ssh-agent") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.ssh-agent {
    systemd = {
      services = {
        # shared ssh-agent
        ssh-agent = {
          wantedBy = [ "multi-user.target" ];
          environment.SSH_AUTH_SOCK = config.environment.variables.SSH_AUTH_SOCK;
          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/rm -f $SSH_AUTH_SOCK";
            ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
            User = lib.mkIf (config.users.users ? marie) "marie";
          };
        };

        "nix-daemon@".environment = {
          inherit (config.environment.variables) SSH_AUTH_SOCK;
          # avoid random magic connection resets
          NIX_SSHOPTS = "-oServerAliveInterval=30";
        };
      };
    };
    environment.variables.SSH_AUTH_SOCK = "/tmp/ssh-agent.socket";
  };
}
