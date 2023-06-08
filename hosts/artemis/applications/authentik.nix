{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    "${inputs.self}/modules/authentik.nix"
    "${inputs.self}/modules/reverse-proxy.nix"
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
      extraConfig = config.uwumarie.reverse-proxy.commonOptions;
    };
  };
  age.secrets.authentik-secrets.file = "${inputs.self}/secrets/authentik-secrets.age";
}
