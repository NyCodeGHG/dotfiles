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
  };
  age.secrets.authentik-secrets.file = ../../secrets/authentik-secrets.age;
}
