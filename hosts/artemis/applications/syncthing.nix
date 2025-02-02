{ config, ... }:
{
  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "marie-desktop".id = "U3EOIRR-FLOIAZH-53X32J7-YRMDHK6-V3DRAIZ-EAZIZR6-DHZMCF3-THYCQQF";
        "delphi".id = "PBHEMSO-H7S6F7I-2LXMQEL-XZLEUOF-QNSQIAO-MSS2B7D-HNRTTKY-5TRDDAO";
      };
      gui.insecureSkipHostcheck = true;
      folders = {
        "cabin-modpack" = {
          path = "/var/lib/syncthing/cabin-modpack";
          devices = [ "delphi" ];
        };
        "transport-fever-2-saves" = {
          path = "/var/lib/syncthing/transport-fever-2-saves";
          label = "Transport Fever 2 Saves";
          id = "jpfpm-rrary";
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
      };
    };
  };
  security.acme.certs."marie.cologne".extraDomainNames = [ "*.artemis.marie.cologne" ];
  services.nginx.virtualHosts."syncthing.artemis.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://${config.services.syncthing.guiAddress}";
      proxyWebsockets = true;
    };
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "syncthing.artemis.marie.cologne" ];
  };
}
