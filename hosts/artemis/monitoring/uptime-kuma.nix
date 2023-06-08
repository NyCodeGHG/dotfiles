{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    "${inputs.self}/modules/reverse-proxy.nix"
  ];
  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
  };
  uwumarie.reverse-proxy.services = {
    "uptime-kuma.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
        extraConfig = ''
          allow 127.0.0.1/24;
          allow 10.69.0.1/24;
          deny all;
        '';
      };
    };
    "status.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
      };
    };
  };
}
