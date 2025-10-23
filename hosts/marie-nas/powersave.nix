{ ... }:
{
  powerManagement = {
    enable = true;
    scsiLinkPolicy = "med_power_with_dipm";
    powertop.enable = true;
  };
  services.power-profiles-daemon.enable = true;
}
