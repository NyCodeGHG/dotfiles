{ config, pkgs, lib, ... }:
{
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
  };

  age.secrets.cloudflare-api-key.file = ../../secrets/cloudflare-api-key.age;
}
