{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uwumarie.profiles.dns = lib.mkEnableOption ("dns config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.dns {
    services.resolved = {
      enable = lib.mkDefault true;
      extraConfig = ''
        DNS=2620:fe::fe#dns.quad9.net
        DNS=2620:fe::9#dns.quad9.net
        DNS=9.9.9.9#dns.quad9.net
        DNS=149.112.112.112#dns.quad9.net
        LLMNR=no
      '';
      dnsovertls = lib.mkDefault "true";
    };
  };
}
