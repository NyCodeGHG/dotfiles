{ config, lib, ... }:
{
  options.uwumarie.profiles.nginx.enable = lib.mkEnableOption (lib.mdDoc "nginx config");
  options.uwumarie.profiles.nginx.monitoring.enable = lib.mkEnableOption (lib.mdDoc "nginx monitoring") // {
    default = true;
  };
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.forceSSL = lib.mkDefault true;
      config.http2 = lib.mkDefault true;
      config.useACMEHost = lib.mkDefault "marie.cologne";
    });
  };
  config = lib.mkIf config.uwumarie.profiles.nginx.enable {
    services.nginx = {
      enable = true;
      virtualHosts."_" = {
        default = true;
        locations."/" = {
          return = "404";
        };
      };
      virtualHosts.localhost = {
        forceSSL = false;
        http2 = false;
        useACMEHost = null;
      };
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      recommendedProxySettings = true;
    };
  };
}
