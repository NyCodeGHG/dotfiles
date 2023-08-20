{ lib, ... }:
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.forceSSL = lib.mkDefault true;
      config.http2 = lib.mkDefault true;
      config.useACMEHost = lib.mkDefault "marie.cologne";
    });
  };

  config = {
    services.nginx = {
      enable = true;
      virtualHosts."_" = {
        default = true;
        locations."/" = {
          return = "404";
        };
      };
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      recommendedZstdSettings = true;
      recommendedProxySettings = true;
    };
  };
}
