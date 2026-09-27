{
  pkgs,
  lib,
  config,
  ...
}:
let
  useInsecure = true;
  useStaging = true;
in
{
  systemd.services.fritz-tls = {
    description = "Renew Fritz!Box TLS Certificate";
    documentation = [ "https://github.com/tisba/fritz-tls" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      ExecStart = lib.concatStringsSep " " (
        [
          (lib.getExe pkgs.fritz-tls)
          "--host https://tlsautomation@fritzbox.home.marie.cologne"
          "--password-file %d/fritz-password"
          "--dns-provider cloudflare"
        ]
        ++ lib.optional useInsecure "--insecure"
        ++ lib.optional useStaging "--acme-server https://acme-staging-v02.api.letsencrypt.org/directory"
      );
      EnvironmentFile = config.age.secrets.cloudflare-api-key.path;
      LoadCredential = "fritz-password:${config.age.secrets.fritz-password.path}";
    };
    startAt = "daily";
  };

  age.secrets.fritz-password.file = ./fritz-password.age;
}
