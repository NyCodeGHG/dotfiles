{ config, ... }:
let
  users = {
    home-assistant = {
      acl = [ "readwrite #" ];
      hashedPassword = "$7$101$jciHmAP1k0FT5S9f$yb56LgOsiU+qfHUJswA6Jz6qBYZLbOnRZHwAkFj9K1dEbLwW4DBUNiN+/+4eErkUskPUGIZYAjcRQRn1qFYIaQ==";
    };
    sleepasandroid = {
      acl = [ "readwrite SleepAsAndroid/#" ];
      hashedPassword = "$7$101$cpOXOPwrgPxKAPYm$cSI0e3lyTBaWlkfDSaJJ1mjatNS+lPGIqnRIS8sIUe5KtR6/2SLTdDby/51Lx361h0b1cvf7hc2vMwIYppzMHg==";
    };
  };
in
{
  security.acme.certs."mqtt.home.marie.cologne" = { };

  systemd.services.mosquitto = {
    after = [ "acme-mqtt.home.marie.cologne.service" ];
    serviceConfig = {
      SupplementaryGroups = "acme";
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = 1883;
        inherit users;
        address = "0.0.0.0";
        settings.allow_anonymous = false;
      }
      {
        port = 8883;
        inherit users;
        settings =
          let
            certDir = config.security.acme.certs."mqtt.home.marie.cologne".directory;
          in
          {
            certfile = "${certDir}/cert.pem";
            keyfile = "${certDir}/key.pem";
            cafile = "${certDir}/chain.pem";
            allow_anonymous = false;
          };
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 1883 8883 ];
}
