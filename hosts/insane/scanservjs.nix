{ config, pkgs, lib, ... }:
{
  services.scanservjs.enable = false;
  services.scanservjs.package = pkgs.scanservjs.overrideAttrs (prev: {
    patches = prev.patches ++ [
      (pkgs.fetchpatch {
        url = "https://github.com/NyCodeGHG/scanservjs/commit/9479c49179c0fa9235119ee6fc97a3b484def3e0.patch";
        sha256 = "sha256-N0ANlHBMcEVqhXRKkcRBH78O1RVFJ4fjEH+gKcaxBZk=";
      })
    ];
  });
  hardware.sane = {
    enable = true;
    openFirewall = true;
    brscan4 = {
      enable = true;
      netDevices.druckilein = {
        ip = "192.168.178.119";
        model = "MFC-J430W";
      };
    };
  };

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
