{
  services.victoriametrics = {
    enable = true;
    retentionPeriod = "30d";
    extraOptions = [
      "-enableTCP6"
    ];
  };

  services.nginx.virtualHosts."metrics.artemis.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:8428";
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
