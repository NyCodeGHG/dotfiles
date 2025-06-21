{ pkgs, ... }:
{
  services.victorialogs.enable = true;

  services.victorialogs.package =
    (pkgs.victoriametrics.overrideAttrs (prev: {
      pname = "VictoriaLogs";
      version = "1.24.0";

      src = pkgs.fetchFromGitHub {
        owner = "victoriametrics";
        repo = "victoriametrics";
        tag = "v1.24.0-victorialogs";
        hash = "sha256-E52hvxazzbz9FcPFZFcRHs2vVg6fJJQ8HsieQovQSi4=";
      };

      prePatch = ''
        substituteInPlace go.mod --replace-fail '1.24.4' '1.24.3'
      '';
    })).override
      {
        withServer = false; # the actual metrics server
        withVmAgent = false; # Agent to collect metrics
        withVmAlert = false; # Alert Manager
        withVmAuth = false; # HTTP proxy for authentication
        withBackupTools = false; # vmbackup, vmrestore
        withVmctl = false; # vmctl is used to migrate time series
        withVictoriaLogs = true; # logs server
      };

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
