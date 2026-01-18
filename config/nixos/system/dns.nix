{
  config,
  lib,
  ...
}:
let
  version = lib.removeSuffix "pre-git" lib.version;
in
{
  options.uwumarie.profiles.dns = lib.mkEnableOption ("dns config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.dns {
    services.resolved = {
      enable = lib.mkDefault true;
    }
    // lib.optionalAttrs (lib.versionOlder version "26.05") {
      extraConfig = ''
        DNS=2620:fe::fe#dns.quad9.net
        DNS=2620:fe::9#dns.quad9.net
        DNS=9.9.9.9#dns.quad9.net
        DNS=149.112.112.112#dns.quad9.net
        LLMNR=no
      '';
    }
    // lib.optionalAttrs (lib.versionAtLeast version "26.05") {
      settings.Resolve = {
        DNS = [
          "2620:fe::fe#dns.quad9.net"
          "2620:fe::9#dns.quad9.net"
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
        ];
        DNSOverTLS = "opportunistic";
        LLMNR = false;
      };
    };
  };
}
