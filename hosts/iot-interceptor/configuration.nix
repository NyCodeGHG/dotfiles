{
  inputs,
  modulesPath,
  config,
  ...
}:
{
  imports = [
    ./networking.nix
    ./volatile-journal.nix
    ./monitoring.nix
    ./interceptor.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
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
      };
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
    dns = false;
    locale = false;
  };

  uwumarie.agenix.enable = true;

  boot = {
    tmp.useTmpfs = true;
    initrd.systemd.emergencyAccess = true;
  };

  services.userborn.enable = true;

  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
