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
    extraArgs = [
      "--user-agent"
      "iplookupd - me@nycode.dev"
    ];
  };

  systemd.services.iplookupd.environment = {
    HTTPS_PROXY = "socks5://marie-nas:8888";
  };

  services.nginx.virtualHosts."iplookupd.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:7805";
    };
  };
}
