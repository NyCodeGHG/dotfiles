{ lib, config, ... }:
{
  options.uwumarie.profiles.zram = lib.mkEnableOption "zram" // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.zram {
    services.zram-generator = {
      enable = true;
      settings = {
        zram0.zram-size = "min(ram / 2, 4096)";
      };
    };
  };
}
