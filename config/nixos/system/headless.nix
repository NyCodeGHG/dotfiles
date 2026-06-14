{ lib, config, pkgs, ... }:
{
  options.uwumarie.profiles.headless = lib.mkEnableOption "headless profile";
  config = lib.mkIf config.uwumarie.profiles.headless {
    environment.stub-ld.enable = false;
    networking.firewall.logRefusedConnections = false;
    powerManagement.enable = lib.mkDefault false;

    environment.systemPackages = [
      pkgs.hyfetch
    ];
  };
}
