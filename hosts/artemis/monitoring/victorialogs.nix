{
  services.victorialogs.enable = true;

  services.nginx.virtualHosts."logs.artemis.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:9428";
      proxyWebsockets = true;
    };
    extraConfig = ''
      allow 127.0.0.1/32;
      allow ::1/128;
      allow 100.64.0.0/10;
      allow fd7a:115c:a1e0::/48;
      deny all;
    '';
  };
}
