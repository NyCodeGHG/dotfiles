{ config, lib, pkgs, inputs, ... }:
{
  options.uwumarie.profiles.base = lib.mkEnableOption (lib.mdDoc "The base config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.base {
    environment.systemPackages = with pkgs; [
      htop
      fastfetch
      pciutils
      file
      iputils
      dnsutils
      usbutils
      wget
      curl
      vim
      tcpdump
      git
      fd
    ];
    programs.nano.enable = false;
    security.sudo-rs.enable = true;
  };
}
