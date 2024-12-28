{ config, pkgs, inputs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (inputs.nixpkgs-unstable.legacyPackages.${system}) netbox_4_1;
in
{
  disabledModules = [ "services/web-apps/netbox.nix" ];
  imports = [
    (inputs.nixpkgs-unstable + "/nixos/modules/services/web-apps/netbox.nix")
  ];
  services.netbox = {
    enable = false;
    package = netbox_4_1.overrideAttrs (prev: {
      installPhase = prev.installPhase + ''
        cp ${./custom_pipeline.py} $out/opt/netbox/netbox/netbox/custom_pipeline.py
      '';
    });
    port = 8002;
    secretKeyFile = config.age.secrets.netbox-secret.path;
    settings = {
      ALLOWED_HOSTS = [ "netbox.marie.cologne" ];
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
      SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = "https://sso.nycode.dev/application/o/netbox/";
      SOCIAL_AUTH_OIDC_KEY = "tbbNu0tJBqY4rT6QKLFWl7Hgra4Wvg2YYPl7VZoT";
      LOGOUT_REDIRECT_URL = "https://sso.nycode.dev/application/o/netbox/end-session/";
    };
    extraConfig = ''
      with open("${config.age.secrets.netbox-client-secret.path}", "r") as file:
          SOCIAL_AUTH_OIDC_SECRET = file.readline()

      SOCIAL_AUTH_PIPELINE = (
        'social_core.pipeline.social_auth.social_details',
        'social_core.pipeline.social_auth.social_uid',
        'social_core.pipeline.social_auth.social_user',
        'social_core.pipeline.user.get_username',
        'social_core.pipeline.user.create_user',
        'social_core.pipeline.social_auth.associate_user',
        'netbox.authentication.user_default_groups_handler',
        'social_core.pipeline.social_auth.load_extra_data',
        'social_core.pipeline.user.user_details',
        'netbox.custom_pipeline.add_groups',
        'netbox.custom_pipeline.remove_groups',
        'netbox.custom_pipeline.set_roles'
      )
    '';
  };
  age.secrets = {
    netbox-secret = {
      file = ../../secrets/netbox-secret.age;
      owner = "netbox";
      group = "netbox";
    };
    netbox-client-secret = {
      file = ../../secrets/netbox-client-secret.age;
      owner = "netbox";
      group = "netbox";
    };
  };
  users.users.nginx.extraGroups = [ "netbox" ];
  services.nginx.virtualHosts."netbox.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://${config.services.netbox.listenAddress}:${toString config.services.netbox.port}";
      proxyWebsockets = true;
    };
    locations."/static/" = {
      root = config.services.netbox.dataDir;
    };
  };
}
