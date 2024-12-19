{ lib, config, pkgs, ... }:
{
  options.uwumarie.profiles.ntp = (lib.mkEnableOption "ntp config") // { default = true; };
  config = lib.mkIf config.uwumarie.profiles.ntp {
    services = {
      timesyncd.enable = false;
      ntpd-rs = {
        enable = true;
        useNetworkingTimeServers = true;
        metrics.enable = true;
        settings.observability.log-level = "info";
      };
    };
  };
}
