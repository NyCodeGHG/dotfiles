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
    boot = {
      tmp.useTmpfs = true;
      initrd.systemd = {
        enable = true;
        emergencyAccess = true;
      };

      # enable TCP BBR for hopefully better utilization
      kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
    };

    services = {
      openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
        };
      };

      journald.extraConfig = "SystemMaxUse=100M";

      orca.enable = false;
      speechd.enable = false;
    };

    environment.systemPackages = with pkgs; [
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
      jq
      b3sum
      bpftrace
      lix-diff
      (lib.lowPrio neovim-unwrapped)
    ];

    security.sudo-rs.enable = lib.mkDefault true;

    programs.command-not-found.enable = false;

    documentation.nixos.enable = lib.mkDefault false;

    networking.nftables.enable = lib.mkDefault true;

    virtualisation.containers.containersConf.settings = {
      network.firewall_driver = lib.mkIf config.networking.nftables.enable "nftables";
      engine = {
        compose_warning_logs = false;
      };
    };

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

    environment.shellAliases = {
      "man" = lib.mkIf config.documentation.man.enable "nix-locate-man";
      "ffmpeg" = "ffmpeg -hide_banner";
      "ffprobe" = "ffprobe -hide_banner";
      "ffplay" = "ffplay -hide_banner";
      "nrp" = "nix repl --file '<nixpkgs>'";
      "vim" = "nvim";
    };

    security.polkit.enable = lib.mkDefault true;

    services.kmscon = {
      enable = lib.mkDefault true;
      useXkbConfig = true;
      fonts = [
        {
          name = "Fira Mono";
          package = pkgs.fira;
        }
      ];
    };

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_18;
  };
}
