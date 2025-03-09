{ config, lib, ... }:
let
  logFormat = ''$remote_addr - $remote_user [$time_local] "$host" "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"'';
in
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
      appendHttpConfig = ''
        log_format meow '${logFormat}';
        access_log /var/log/nginx/access.log meow;
      '';
    };

    services.prometheus.exporters.nginxlog = {
      enable = config.uwumarie.profiles.nginx.monitoring.enable;
      group = "nginx";
      settings.namespaces = [
        {
          name = "nginx";
          format = logFormat;
          source.files = ["/var/log/nginx/access.log"];
          relabel_configs = [
            { target_label = "host"; from = "host"; }
            { target_label = "user_agent"; from = "http_user_agent"; }
            { target_label = "remote_address"; from = "remote_addr"; }
          ];
        }
      ];
    };
  };
}
