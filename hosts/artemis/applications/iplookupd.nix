{
  inputs,
  ...
}:

{
  imports = [
    inputs.iplookupd.nixosModules.default
  ];

  nixpkgs.overlays = [ (inputs.iplookupd.overlays.default) ];

  services.iplookupd = {
    enable = true;
    listen = "http+tcp://localhost:7805";
  };

  services.nginx.virtualHosts."iplookupd.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:7805";
    };
  };
}
