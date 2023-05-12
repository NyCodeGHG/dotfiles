{ config
, pkgs
, ...
}: {
  imports = [
    ../../modules/motd.nix
    ./hardware.nix
    ./acme.nix
    ./postgres.nix
    ./authentik.nix
    ./miniflux.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking = {
    hostName = "artemis";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
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
    passwordAuthentication = false;
    permitRootLogin = "no";
    kbdInteractiveAuthentication = false;
  };
  system.stateVersion = "22.11";

  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp Marie Default"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz Marie Laptop"
    ];
    initialPassword = "";
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts."uwu.nycode.dev" = {
      forceSSL = true;
      useACMEHost = "marie.cologne";
      http2 = true;
    };
    virtualHosts."_" = {
      forceSSL = true;
      http2 = true;
      useACMEHost = "marie.cologne";
      default = true;
    };
  };

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

  services.motd.enable = true;
}
