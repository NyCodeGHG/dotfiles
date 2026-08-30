{
  inputs,
  pkgs,
  modulesPath,
  config,
  ...
}:
{
  imports = [
    ./networking.nix
    ./volatile-journal.nix
    ./monitoring.nix
    # oh god
    (
      { pkgs, lib, ... }@args:
      let
        rpi3 = (import inputs.nixos-hardware.nixosModules.raspberry-pi-3 args);
      in
      rpi3 // { boot = lib.removeAttrs rpi3.boot [ "kernelParams" ]; }
    )
    inputs.agenix.nixosModules.default
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  system.stateVersion = "26.11";

  hardware.raspberry-pi = {
    firmware = {
      enable = true;
      uboot.enable = true;
    };
    configtxt = {
      settings.all = {
        gpu_mem = 16;
        force_eeprom_read = 0;
      };
      deviceTreeOverlays.all = [
        { miniuart-bt = { }; }
      ];
    };
  };

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
  };

  sdImage = {
    firmwareSize = 128;
    compressImage = false;
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  uwumarie.profiles = {
    ssh-agent = false;
    base = false;
    dns = false;
    locale = false;
    zram = false;
  };

  uwumarie.agenix.enable = true;

  boot = {
    kernelParams = [ "console=tty0" ];
    tmp.useTmpfs = true;
    initrd.systemd.emergencyAccess = true;
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
    userborn.enable = true;
  };

  environment.systemPackages = [
    pkgs.btop
  ];

  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = false;
  };
  programs.command-not-found.enable = false;
  documentation.nixos.enable = false;
  users.mutableUsers = false;

  system.tools = {
    nixos-build-vms.enable = false;
    nixos-enter.enable = false;
    nixos-generate-config.enable = false;
    nixos-install.enable = false;
    nixos-option.enable = false;
  };

  security.polkit.enable = true;
}
