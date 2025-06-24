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
    package = pkgs.postgresql_17;
    ensureUsers = [
      {
        name = "traewelldroid-webhookrelay";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "traewelldroid-webhookrelay" ];
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedProxySettings = true;
    virtualHosts."webhookrelay.traewelldroid-prod.marie.cologne" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:3700";
    };
  };
}
