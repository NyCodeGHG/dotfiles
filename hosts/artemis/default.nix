{ config
, pkgs
, ...
}: {
  imports = [
    ../../modules/motd.nix
    ../../modules/nix-config.nix
    ../../profiles/reverse-proxy.nix
    ../../profiles/acme.nix
    ./monitoring
    ./applications
    ./hardware.nix
    ./postgres.nix
    ./wireguard.nix
    ./restic.nix
    ./networking.nix
    ./fail2ban.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  console.keyMap = "de";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    nftables
    iptables
    git
    btop
    neofetch
  ];

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
  system.stateVersion = "22.11";

  virtualisation.vmVariant = {
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
      {
        from = "host";
        host.port = 8080;
        guest.port = 80;
      }
      {
        from = "host";
        host.port = 8443;
        guest.port = 443;
      }
    ];
    virtualisation = {
      graphics = false;
      memorySize = 1024;
      cores = 4;
      diskSize = 1024 * 8;
    };
  };
  uwumarie.services.motd.enable = true;
}
