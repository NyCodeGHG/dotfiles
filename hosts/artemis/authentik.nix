{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/authentik.nix
  ];

  virtualisation.podman.enable = true;
  uwumarie.services.authentik = {
    enable = true;
    environmentFiles = [
      config.age.secrets.authentik-secrets.path
    ];
    ldap = {
      enable = false;
    };
    nginx = {
      enable = true;
      domain = "sso.nycode.dev";
      extraConfig = {
        forceSSL = true;
        http2 = true;
        useACMEHost = "marie.cologne";
      };
    };
  };
  age.secrets.authentik-secrets.file = ../../secrets/authentik-secrets.age;
}
