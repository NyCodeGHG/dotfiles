{ pkgs, ... }:
{
  services.postgresql = {
    ensureDatabases = [
      "untis-caldav-sync-staging"
    ];
    ensureUsers = [
      {
        name = "untis-caldav-sync-staging";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.etc."containers/systemd/untis-caldav-sync-staging.container".source =
    ./staging.container;

  users.users.untis-caldav-sync-staging = {
    isSystemUser = true;
    group = "untis-caldav-sync-staging";
    uid = 964;
  };
  users.groups.untis-caldav-sync-staging = {
    gid = 958;
  };

  systemd.timers.podman-auto-update = {
    enable = true;
    wantedBy = [ "timers.target" ];
  };

  age.secrets.untis-caldav-sync-staging-env.file = ./staging-env.age;

  services.nginx.virtualHosts."staging.untis-caldav-sync.marie.cologne" = {
    useACMEHost = null;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3002";
    };
    locations."/robots.txt" = {
      extraConfig = ''
        return 200 "User-agent: *\nDisallow: /\n";
      '';
    };
    locations."/metrics" = {
      proxyPass = "http://localhost:3002";
      extraConfig = ''
        allow 127.0.0.0/24;
        deny all;
      '';
    };
  };
}
