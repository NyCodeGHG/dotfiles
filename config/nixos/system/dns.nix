{ config, lib, pkgs, ... }:
{
  options.uwumarie.profiles.dns = lib.mkEnableOption ("dns config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.dns {
    # use quad9 dns services
    networking.nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
  };
}
