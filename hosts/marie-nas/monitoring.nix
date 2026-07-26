{ config, ... }:
{
  services.prometheus.exporters.smartctl.enable = true;
  environment.etc."alloy/smartctl.alloy".text = ''
    scrape_local "smartctl" {
      name = "smartctl"
      port = ${toString config.services.prometheus.exporters.smartctl.port}
    }
  '';
}
