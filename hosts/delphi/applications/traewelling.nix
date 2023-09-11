{ config, self, ... }:
{
  imports = [
    self.nixosModules.traewelling
  ];
  services.traewelling = {
    enable = true;
    domain = "trwl-staging.marie.cologne";
    nginx = {
      forceSSL = true;
      http2 = true;
      useACMEHost = "marie.cologne";
    };
    secretFile = config.age.secrets.traewelling-env.path;
  };
  age.secrets.traewelling-env.file = "${self}/secrets/traewelling-env.age";
}
