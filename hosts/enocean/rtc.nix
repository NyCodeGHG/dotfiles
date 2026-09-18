{ pkgs, ... }:
{
  hardware.raspberry-pi.configtxt.deviceTreeOverlays.all = [
    { i2c-rtc.mcp7941x = true; }
  ];

  boot.initrd.kernelModules = [
    "i2c-bcm2835"
    "rtc-ds1307"
  ];

  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.i2c-tools ];
}
