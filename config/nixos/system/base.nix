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

    programs.fuse.enable = true;

    services = {
      openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
        };
      };

      journald.settings.Journal = {
        SystemMaxUse = lib.mkDefault "100M";
      };

      orca.enable = false;
      speechd.enable = false;
    };

    environment.systemPackages = with pkgs; [
      btop
      pciutils
      file
      iputils
      dnsutils
      usbutils
      curl
      tcpdump
      git
      fd
      bat
      ripgrep
      pv
      jq
      b3sum
      bpftrace
      lix-diff
      (lib.lowPrio neovim-unwrapped)
      cryptsetup
      sshfs
      socat
      tinyxxd
      tailcat
      conntrack-tools
    ];

    security.sudo-rs.enable = lib.mkDefault true;

    programs.command-not-found.enable = false;

    documentation.nixos.enable = lib.mkDefault false;

    networking = {
      nftables = {
        enable = lib.mkDefault true;
        flushRuleset = false;
      };
      firewall.filterForward = lib.mkDefault true;
    };

    virtualisation.containers.containersConf.settings.engine = {
      compose_warning_logs = false;
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
      "man" = lib.mkIf (lib.elem pkgs.nix-locate-man config.environment.systemPackages) "nix-locate-man";
      "ffmpeg" = "ffmpeg -hide_banner";
      "ffprobe" = "ffprobe -hide_banner";
      "ffplay" = "ffplay -hide_banner";
      "nrp" = "nix repl --file '<nixpkgs>'";
      "vim" = "nvim";
      "nginx-config" =
        lib.mkIf config.services.nginx.enable "systemctl cat nginx | grep -oP '\\/nix\\/store\\/\\w+-nginx\\.conf' -m 1";
    };

    security.polkit.enable = lib.mkDefault true;

    fonts.packages = [ pkgs.fira ];

    services.kmscon = {
      enable = lib.mkDefault true;
      useXkbConfig = true;
      config = {
        font-name = "Fira Mono";
      };
    };
  };
}
