{ ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "network_route"
      "systemd"
    ];
  };
}
