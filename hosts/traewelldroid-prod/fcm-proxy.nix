{
  pkgs,
  lib,
  config,
  ...
}:
let
  configFile = (pkgs.formats.toml { }).generate "config.toml" {
    listenAddr = "localhost:5000";
    verbose = true;
    rewrite.webpushfcm.enabled = true;
  };
in
{
  systemd.services.fcm-proxy = {
    description = "Firebase Cloud Messaging Proxy";
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.unifiedpush-common-proxies} -c ${configFile}";
      DynamicUser = true;
      ProtectSystem = "full";
      LoadCredential = "fcm-credentials:${config.age.secrets.fcm-credentials.path}";
    };
    environment = {
      UP_REWRITE_WEBPUSH_FCM_CREDENTIALS_PATH = "%d/fcm-credentials";
    };

    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];
  };

  services.nginx = {
    virtualHosts."fcm-proxy.traewelldroid-prod.marie.cologne" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:5000";
    };
  };

  age.secrets.fcm-credentials.file = ./secrets/fcm-credentials.age;
}
