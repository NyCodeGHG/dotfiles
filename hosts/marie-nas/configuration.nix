{ pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./state.nix
    ./zfs.nix
    ./hardware.nix
    ./powersave.nix
    ./filesystems.nix
    ./initrd-ssh.nix
    ./samba.nix
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

  uwumarie.profiles = {
    headless = true;
  };

  users.users.marie.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs0W2PBnnSG7LvyE0TnfnFjzaC4tbRludscIZM+SWci" ];

  environment.systemPackages = with pkgs; [
    fio
    efibootmgr
    magic-wormhole
    rclone
    tmux
  ];

  systemd.enableEmergencyMode = true;
  security.sudo-rs.wheelNeedsPassword = false;

  system.stateVersion = "24.11";
}
