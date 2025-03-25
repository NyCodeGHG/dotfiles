{ config, inputs, ... }:
{
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
    };
  };
  age.secrets.authentik-secrets.file = "${inputs.self}/secrets/authentik-secrets.age";

  services.nginx.virtualHosts."sso.nycode.dev" = {
    extraConfig = ''
      error_page 401 /sso_unavailable.html;

      location = /sso_unavailable.html {
        root ${./nginx};
        internal;
      }
    '';
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "sso.nycode.dev" ];
  };
}
