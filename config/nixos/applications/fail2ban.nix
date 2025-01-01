{ config, lib, ... }:
{
  options.uwumarie.profiles.fail2ban = lib.mkEnableOption (lib.mdDoc "fail2ban config");
  config = lib.mkIf config.uwumarie.profiles.fail2ban {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        "10.69.0.0/24"
        "127.0.0.1/8"
      ] ++ lib.optional config.services.tailscale.enable "100.64.0.0/10";
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
        pgrokd = {
          enabled = true;
          settings = {
            filter = "pgrokd";
            maxretry = 3;
            port = 2222;
            findtime = "1h";
            bantime = "2w";
            backend = "systemd";
            action = "nftables[port=2222]";
          };
        };
      };
    };
    environment.etc."fail2ban/filter.d/pgrokd.conf".text =
      ''
        [Definition]
        failregex = Failed to handshake remote=<HOST>:\d+
        journalmatch = _SYSTEMD_UNIT=pgrok.service
      '';
  };
}
