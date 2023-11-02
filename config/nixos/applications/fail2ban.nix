{ config, lib, ... }:
{
  options.uwumarie.profiles.fail2ban = lib.mkEnableOption (lib.mdDoc "fail2ban config");
  config = lib.mkIf config.uwumarie.profiles.fail2ban {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        "10.69.0.0/24"
        "127.0.0.1/8"
      ];
      bantime-increment = {
        enable = true;
        maxtime = "48h";
        overalljails = true;
        rndtime = "1h";
      };
      bantime = "1h";
      maxretry = 5;
      jails = {
        sshd = {
          enabled = true;
          settings = {
            mode = "aggressive";
          };
        };
      };
    };
  };
}
