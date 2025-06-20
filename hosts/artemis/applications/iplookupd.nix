{
  inputs,
  ...
}:

{
  imports = [
    inputs.iplookupd.nixosModules.default
  ];

  nixpkgs.overlays = [ (inputs.iplookupd.overlays.default) ];

  services.iplookupd.enable = true;

  services.nginx.virtualHosts."iplookupd.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://unix:/run/iplookupd.sock";
    };
  };
}
