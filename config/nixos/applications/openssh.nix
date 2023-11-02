{ config, lib, ... }:
{
  options.uwumarie.profiles.openssh = lib.mkEnableOption (lib.mdDoc "openssh config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.openssh {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
