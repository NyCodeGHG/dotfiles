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
        tcpdump
        git
        fd
        bat
        ripgrep
        inxi
        pv
        cyme
        rdap
        jq
        systemd-impersonate
        b3sum
        bpftrace
        lix-diff
        neovim-unwrapped
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

    virtualisation.containers.containersConf.settings.network.firewall_driver =
      lib.mkIf config.networking.nftables.enable "nftables";

    users.mutableUsers = false;

    systemd = {
      oomd = {
        enableRootSlice = true;
        enableUserSlices = true;
        enableSystemSlice = true;
      };
      services.sshd.serviceConfig.MemoryMin = "100M";
      tmpfiles.rules = [ "d /var/tmp/nix 1777 root root 1d" ];
    };

    system.tools = {
      nixos-build-vms.enable = false;
      nixos-enter.enable = false;
      nixos-generate-config.enable = false;
      nixos-install.enable = false;
      nixos-option.enable = false;
    };

    environment.variables = {
      "PAGER" = "less";
      "LESS" = "-FRXi -x4 --use-color -Dd+r\\$Du+b";
      "EDITOR" = "nvim";
    };

    security.polkit.enable = lib.mkDefault true;
  };
}
