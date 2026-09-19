{ config, ... }:
{
  imports = [
    ../../config/nixos/system/lxc-image.nix
  ];

  services.victoriametrics = {
    enable = true;
    retentionPeriod = "10y";
    prometheusConfig.scrape_configs = [
      {
        job_name = "nixos-channels";
        scheme = "https";
        metrics_path = "/federate";
        honor_labels = true;
        honor_timestamps = true;
        scrape_interval = "60s";
        params."match[]" = [ ''{job="channel-updates",__name__!~"channel_request_.*"}'' ];
        static_configs = [ { targets = [ "prometheus.nixos.org" ]; } ];
      }
    ];
  };

  networking.hostName = "prom-archiver";

  networking.firewall.allowedTCPPorts = [ 8428 ];
  environment.systemPackages = [ config.services.victoriametrics.package ];

  system.stateVersion = "26.11";
}
