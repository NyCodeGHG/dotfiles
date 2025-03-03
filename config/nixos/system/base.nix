{ config, lib, pkgs, ... }:
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
      wget2
      curl
      wcurl
      vim
      tcpdump
      git
      fd
      bat
      ripgrep
      inxi
      pv
    ];
    programs.trippy.enable = true;
    programs.nano.enable = false;
    security.sudo-rs.enable = lib.mkDefault true;
    programs.command-not-found.enable = false;
    documentation.nixos.enable = lib.mkDefault false;
    boot.initrd.systemd.enable = lib.mkDefault true;
    programs.traceroute.enable = true;
    systemd.network.enable = true;
    boot.tmp.useTmpfs = lib.mkDefault true;
  };
}
