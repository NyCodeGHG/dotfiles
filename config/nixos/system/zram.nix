{ lib, config, ... }:
let
  hasSwapDevice = config.swapDevices != [ ];
in
{
  options.uwumarie.profiles.zram = lib.mkEnableOption "zram" // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.zram {
    services.zram-generator = lib.mkIf (!hasSwapDevice) {
      enable = true;
      settings = {
        zram0.zram-size = "min(ram, 8192)";
      };
    };
    boot.zswap.enable = hasSwapDevice;
  };
}
