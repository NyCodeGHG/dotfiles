{ ... }:
{
  services.matterjs-server = {
    enable = true;
    listenAddress = "::1";
    extraArgs = [
      "--primary-interface=br0"
      "--log-level=warning"
    ];
  };

  services.nginx.virtualHosts."matterjs.home.marie.cologne" = {
    useACMEHost = "matterjs.home.marie.cologne";
    locations."/" = {
      proxyPass = "http://[::1]:5580";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."matterjs.home.marie.cologne" = { };
}
