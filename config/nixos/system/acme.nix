{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.uwumarie.profiles.acme = lib.mkEnableOption (lib.mdDoc "acme config");
  config = lib.mkIf config.uwumarie.profiles.acme {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "tabmeier12+acme@gmail.com";
    security.acme.defaults = {
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      credentialsFile = config.age.secrets.cloudflare-api-key.path;
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };

    security.acme.certs."marie.cologne" = {
      domain = "*.marie.cologne";
      extraDomainNames = [
        "marie.cologne"
        "nycode.dev"
        "*.nycode.dev"
      ];
    };

    users.users.nginx.extraGroups = [ "acme" ];

    age.secrets.cloudflare-api-key.file = "${inputs.self}/secrets/cloudflare-api-key.age";
  };
}
