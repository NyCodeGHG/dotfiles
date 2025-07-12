{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uwumarie.profiles.base = lib.mkEnableOption (lib.mdDoc "The base config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.base {
    environment.systemPackages =
      with pkgs;
      [
        htop
        btop
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
        cyme
      ]
      ++ lib.optionals (!(lib.versionOlder "25.05" lib.trivial.release)) (with pkgs; [ wcurl ]);
    programs.trippy.enable = true;
    programs.nano.enable = false;
    security.sudo-rs.enable = lib.mkDefault true;
    programs.command-not-found.enable = false;
    documentation.nixos.enable = lib.mkDefault false;
    boot.initrd.systemd.enable = lib.mkDefault true;
    programs.traceroute.enable = true;
    systemd.network.enable = lib.mkDefault true;
    boot.tmp.useTmpfs = lib.mkDefault true;

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_12;

    networking.nftables.enable = lib.mkDefault true;
  };
}
