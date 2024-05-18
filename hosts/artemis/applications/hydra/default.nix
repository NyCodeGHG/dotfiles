{ config, ... }:
{
  uwumarie.cachix-upload = {
    enable = true;
    cache = "uwumarie";
    packages = [ "mongodb" ];
    cachixTokenFile = config.age.secrets.cachix-auth-token.path;
  };
  age.secrets.cachix-auth-token.file = ./cachix-auth-token.age;
  services.hydra = {
    enable = true;
    notificationSender = "hydra@localhost";
    hydraURL = "https://hydra.marie.cologne";
    port = 4000;
    useSubstitutes = true;
  };
  nix.buildMachines = [{
    hostName = "warpgate.jemand771.net";
    system = "x86_64-linux";
    sshUser = "marie-hydra:gitlabber-builder";
    protocol = "ssh";
  }];
  services.nginx.virtualHosts."hydra.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
      proxyWebsockets = true;
    };
  };
}
