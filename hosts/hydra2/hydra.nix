{
  pkgs,
  inputs,
  config,
  ...
}:
{
  # Use Lix overlay nix
  nix.package = pkgs.nix;
  imports = [
    inputs.hydra.nixosModules.overlayNixpkgsForThisHydra
  ];
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.marie.cologne";
    notificationSender = "hydra@marie.cologne";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
    port = 3001;
  };

  services.nginx.virtualHosts = {
    "hydra2.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://[::1]:3001";
        proxyWebsockets = true;
      };
      forceSSL = true;
      http2 = true;
      enableACME = true;
      useACMEHost = null;
    };
  };
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
  nix = {
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@wheel" ];
      builders-use-substitutes = true;
      build-dir = "/var/tmp/nix";
      max-jobs = 1;
      cores = 4;
    };
  };
}
