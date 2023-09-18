{ config, pkgs, ... }:
{
  systemd.services.scanservjs-data-setup = {
    description = "ScanServJS: data setup";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ bash rsync ];

    serviceConfig = {
      Type = "oneshot";
      User = "scanservjs";
      Group = "scanservjs";
      StateDirectory = "scanservjs";
      UMask = "077";
    };
    script = ''
      mkdir -p /var/lib/scanservjs/config
      rsync -av --no-perms ${pkgs.scanservjs}/config-static/ /var/lib/scanservjs/config
      mkdir -p /var/lib/scanservjs/data
      rsync -av --no-perms ${pkgs.scanservjs}/data-static/ /var/lib/scanservjs/data
    '';
  };

  systemd.services.scanservjs =
    let
      scanservjs = pkgs.scanservjs.override {
        extraBackends = config.hardware.sane.extraBackends;
      };
    in
    {
      description = "ScanServJS";
      wantedBy = [ "multi-user.target" ];
      after = [ "scanservjs-data-setup.service" ];
      requires = [ "scanservjs-data-setup.service" ];

      serviceConfig = {
        ExecStart = "${scanservjs}/bin/scanservjs";
        User = "scanservjs";
        Group = "scanservjs";
        # StateDirectory = "scanservjs";
        # UMask = "077";
        WorkingDirectory = "/var/lib/scanservjs";
      };
      environment = {
        SANE_CONFIG_DIR = "/etc/sane-config";
        LD_LIBRARY_PATH = "/etc/sane-libs";
      };
    };

  users.users.scanservjs = {
    isSystemUser = true;
    home = "/var/lib/scanservjs";
    group = "scanservjs";
    extraGroups = [ "scanner" ];
  };
  users.groups.scanservjs = { };

  hardware.sane = {
    enable = true;
    openFirewall = true;
    # netConf = "192.168.178.119";
    # extraBackends = with pkgs; [ sane-airscan ];
    brscan4 = {
      enable = true;
      netDevices.druckilein = {
        ip = "192.168.178.119";
        model = "MFC-J430W";
      };
    };
  };

  services.saned.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
    reflector = true;
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true;
}
