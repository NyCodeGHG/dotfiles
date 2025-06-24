{ lib, ... }:
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.forceSSL = lib.mkDefault true;
        config.http2 = lib.mkDefault true;
        config.useACMEHost = lib.mkOverride 500 null;
      }
    );
  };
}
