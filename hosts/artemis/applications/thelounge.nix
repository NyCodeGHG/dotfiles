{
  services.thelounge = {
    enable = true;
    public = false;
    extraConfig = {
      reverseProxy = true;
      port = 9001;
      prefetchStorage = true;
      prefetch = true;
    };
  };

  services.nginx.virtualHosts."irc.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:9001";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50m;
      '';
    };
  };
}
