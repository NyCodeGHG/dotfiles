{ lib, config, ... }:
{
  options.uwumarie.profiles.headless = lib.mkEnableOption "headless profile";
  config = lib.mkIf config.uwumarie.profiles.headless {
    fonts.fontconfig.enable = false;
    environment.stub-ld.enable = false;
    networking.firewall.logRefusedConnections = false;
    powerManagement.enable = lib.mkDefault false;
  };
}
