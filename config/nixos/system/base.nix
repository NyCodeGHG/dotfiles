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
      vim
      tcpdump
      git
      fd
      bat
      ripgrep
      inxi
      pv
    ];
    programs.nano.enable = false;
    security.sudo-rs.enable = true;
    services.lvm.enable = lib.mkDefault false;
    programs.command-not-found.enable = false;
    documentation.nixos.enable = lib.mkDefault false;
    boot.initrd.systemd.enable = true;
  };
}
