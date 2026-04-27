{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.uwumarie.profiles.openssh = {
    enable = lib.mkEnableOption (lib.mdDoc "openssh config") // {
      default = true;
    };
    ssh-agent = lib.mkEnableOption (lib.mdDoc "System wide ssh-agent") // {
      default = true;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.uwumarie.profiles.openssh.enable {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = lib.mkOverride 900 "no";
          KbdInteractiveAuthentication = false;
        };
      };
    })
    (lib.mkIf config.uwumarie.profiles.openssh.ssh-agent {
      systemd = {
        services = {
          # shared ssh-agent
          ssh-agent = {
            wantedBy = [ "multi-user.target" ];
            environment.SSH_AUTH_SOCK = config.environment.variables.SSH_AUTH_SOCK;
            serviceConfig = {
              ExecStartPre = "${pkgs.coreutils}/bin/rm -f $SSH_AUTH_SOCK";
              ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
              User = "marie";
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
    })
  ];
}
