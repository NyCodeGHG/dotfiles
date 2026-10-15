{ config, ... }:
{
  services.prometheus.exporters.fritz = {
    enable = true;
    listenAddress = "::1";
    port = 9787;
    settings = {
      devices = [
        {
          hostname = "fritzbox.home.marie.cologne";
          username = "fritz-exporter";
          password_file = "/run/credentials/prometheus-fritz-exporter.service/password";
          use_tls = true;
        }
      ];
    };
  };

  systemd.services.prometheus-fritz-exporter.serviceConfig = {
    LoadCredential = "password:${config.age.secrets.fritz-exporter-password.path}";
  };

  age.secrets.fritz-exporter-password.file = ./password.age;

  environment.etc."alloy/fritz.alloy".text = ''
    scrape_local "fritz_exporter" {
      name = "fritz_exporter"
      port = ${toString config.services.prometheus.exporters.fritz.port}
    }
  '';
}
