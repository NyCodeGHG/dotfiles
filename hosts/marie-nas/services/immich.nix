{
  services.nginx.virtualHosts."immich.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:2283";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;
      '';
    };
  };

  services.immich = {
    enable = true;
    settings = null;
  };
}
