{ pkgs, inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    ./networking.nix
    ./state.nix
    ./zfs.nix
    ./hardware.nix
    ./powersave.nix
    ./filesystems.nix
    ./initrd-ssh.nix
    ./samba.nix
    ./monitoring.nix
    ./media.nix
    ./services/postgres.nix
  ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_12;
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

  users.users.marie.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs0W2PBnnSG7LvyE0TnfnFjzaC4tbRludscIZM+SWci" ];

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
  ];

  environment.shellAliases = {
    "ffmpeg" = "ffmpeg -hide_banner";
    "ffprobe" = "ffprobe -hide_banner";
    "ffplay" = "ffplay -hide_banner";
  };

  systemd = {
    enableEmergencyMode = false;
    watchdog.runtimeTime = "15s";
  };
  security.sudo-rs.wheelNeedsPassword = false;

  system.stateVersion = "24.11";
}
