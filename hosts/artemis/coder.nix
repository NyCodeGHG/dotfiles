{
  services.coder = {
    enable = true;
    accessUrl = "https://coder.marie.cologne";
    wildcardAccessUrl = "*.coder.marie.cologne";
    database.createLocally = true;
  };
  services.nginx =
    let
      virtualHost = {
        forceSSL = true;
        http2 = true;
        useACMEHost = "marie.cologne";
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://coder";
        };
      };
    in
    {
      upstreams.coder = {
        servers = { "127.0.0.1:3000" = { }; };
      };
      virtualHosts."coder.marie.cologne" = virtualHost;
      virtualHosts."*.coder.marie.cologne" = virtualHost;
    };
}
