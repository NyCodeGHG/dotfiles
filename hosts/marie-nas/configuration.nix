{ pkgs, inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    ../../config/nixos/applications/tailscale.nix
    ../../config/nixos/monitoring
    ../../modules/nixos/cloudflare-dyndns/cloudflare-dyndns.nix
    ./networking.nix
    ./state.nix
    ./zfs.nix
    ./hardware.nix
    ./powersave.nix
    ./filesystems.nix
    ./initrd-ssh.nix
    ./samba.nix
    ./media.nix
    ./services/postgres.nix
    ./services/oauth2-proxy.nix
    ./services/minecraft.nix
    ./services/proxy.nix
    ./services/factorio.nix
    ./services/dyndns.nix
    ./services/incus.nix
    ./services/immich.nix
    ./monitoring.nix

    # Smart Home
    ./services/smart-home/esphome.nix
    ./services/smart-home/home-assistant-matter-hub.nix
    ./services/smart-home/home-assistant.nix
    ./services/smart-home/matter-server.nix
    ./services/smart-home/mosquitto.nix
    ./services/smart-home/music-assistant.nix
    ./services/smart-home/openthread-border-router.nix
    ./services/smart-home/zigbee2mqtt.nix

    # Media
    ./services/media/bazarr.nix
    ./services/media/bitmagnet.nix
    ./services/media/prowlarr.nix
    ./services/media/radarr.nix
    ./services/media/sonarr.nix
    ./services/media/transmission.nix
    ./services/media/vpn.nix
  ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  security.acme.certs."marie.cologne".extraDomainNames = [ "*.marie-nas.marie.cologne" ];

  uwumarie.profiles = {
    headless = true;
    acme = true;
    nginx.enable = true;
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  services.fwupd.enable = true;

  users.users.marie.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs0W2PBnnSG7LvyE0TnfnFjzaC4tbRludscIZM+SWci"
  ];

  environment.systemPackages = with pkgs; [
    fio
    efibootmgr
    magic-wormhole
    rclone
    tmux
    bpftrace
    smartmontools
    hdparm
    ffmpeg
    wireguard-tools
    yt-dlp
    waypipe
  ];

  hardware.graphics.enable = true;

  systemd = {
    enableEmergencyMode = false;
    settings.Manager.RuntimeWatchdogSec = "15s";
  };
  security.sudo-rs.wheelNeedsPassword = false;

  system.stateVersion = "24.11";
}
