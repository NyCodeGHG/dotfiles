{ config, lib, ... }:
{
  options.uwumarie.profiles.nginx.enable = lib.mkEnableOption (lib.mdDoc "nginx config");
  options.uwumarie.profiles.nginx.monitoring.enable =
    lib.mkEnableOption (lib.mdDoc "nginx monitoring")
    // {
      default = true;
    };
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config = {
          forceSSL = lib.mkDefault true;
          http2 = lib.mkDefault true;
          useACMEHost = lib.mkDefault "marie.cologne";
          http3 = lib.mkDefault true;
          quic = lib.mkDefault true;
        };
      }
    );
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
        http3 = false;
        quic = false;
        useACMEHost = null;
      };
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      recommendedProxySettings = true;
      enableQuicBPF = true;
      appendHttpConfig = ''
        add_header alt-svc 'h3=":443"; ma=604800';
      '';
    };
  };
}
