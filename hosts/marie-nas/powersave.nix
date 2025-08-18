{ ... }:
{
  powerManagement = {
    enable = true;
    scsiLinkPolicy = "med_power_with_dipm";
  };
  services.power-profiles-daemon.enable = true;
}
