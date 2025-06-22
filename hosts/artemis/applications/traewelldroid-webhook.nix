{ pkgs, lib, ... }:
{
  systemd.services.traewelldroid-webhookrelay = {
    description = "Traewelldroid webhook relay";
    after = [
      "network.target"
      "postgresql.service"
    ];
    wants = [
      "network.target"
      "postgresql.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.getExe pkgs.traewelldroid-webhookrelay;
      DynamicUser = true;
    };
    environment = {
      WebhookRelaySettings__SentryDsn = "";
      WebhookRelaySettings__PostgresConnection = "Host=/run/postgresql;Database=traewelldroid-webhookrelay;Username=traewelldroid-webhookrelay;";
      WebhookRelaySettings__Logging = "true";
      ASPNETCORE_URLS = "http://localhost:3700";
    };
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "traewelldroid-webhookrelay";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "traewelldroid-webhookrelay" ];
  };

  services.nginx.virtualHosts."traewelldroid-webhookrelay.marie.cologne" = {
    locations."/".proxyPass = "http://localhost:3700";
  };
}
