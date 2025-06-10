{ pkgs, ... }:
{
  services.victorialogs.enable = true;

  services.victorialogs.package = pkgs.victoriametrics.overrideAttrs (prev: {
    src = pkgs.fetchFromGitHub {
      owner = "victoriametrics";
      repo = "victoriametrics";
      rev = "b001874964314a34e0bd42b335e2ee4624cb61ff";
      hash = "sha256-wJx+BBs5Qs0ycFyptWMh5cwsuBGdWWW1iiQOgTEQ/q0=";
    };

    prePatch = ''
      substituteInPlace go.mod --replace-fail '1.24.4' '1.24.3'
    '';
  });

  services.nginx.virtualHosts."logs.artemis.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:9428";
      proxyWebsockets = true;
    };
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "logs.artemis.marie.cologne" ];
  };

  services.journald.upload = {
    enable = true;
    settings = {
      Upload.URL = "http://localhost:9428/insert/journald";
    };
  };
}
