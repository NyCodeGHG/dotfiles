{ pkgs, modulesPath, config, inputs, ... }:
{
  imports = with inputs; [
    home-manager.nixosModules.default
    agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    (modulesPath + "/profiles/minimal.nix")
    ./hardware.nix
    ./forgejo-runner.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "gitlabber";

  services.qemuGuest.enable = true;

  # use root account instead
  uwumarie.profiles.users.marie = false;
  uwumarie.profiles = {
    headless = true;
    openssh = true;
    nix = true;
  };

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks = {
      "10-ethernet" = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          KeepConfiguration = "yes";
        };
      };
      "50-wg0" = {
        name = "wg0";
        address = [ "fdf1:3ba4:9723:6373::1/64" ];
      };
    };
    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wg-private.path;
        RouteTable = "main";
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          PublicKey = "ph9Pg7QVjZtuWYScyYWBkIgbROcFUSK0JDly/sY+3lQ=";
          AllowedIPs = [ "fd00::/8" ];
          PersistentKeepalive = 5;
          Endpoint = "artemis.marie.cologne:52020";
        };
      }];
    };
  };

  age.secrets.wg-private = {
    file = ./wg-private.age;
    owner = "systemd-network";
    group = "systemd-network";
  };

  services.resolved.enable = true;

  users.users.root = {
    openssh.authorizedKeys.keys = [
      # Warpgate public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFPCqSH26mf3vHii7DUtHRZ33OhSVYpjUMmbTDReS+s"
      # Marie desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
    ];
  };

  users.users.builder = {
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      # Warpgate public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFPCqSH26mf3vHii7DUtHRZ33OhSVYpjUMmbTDReS+s"
      # Marie desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
    ];
    group = "builder";
    shell = pkgs.bashInteractive;
  };
  users.groups.builder = { };

  nix.settings.trusted-users = [ "builder" ];

  services.openssh.settings.PermitRootLogin = "prohibit-password";

  system.stateVersion = "23.11";

  environment.systemPackages = with pkgs; [ 
    rsync
    nix-output-monitor
    tmux
  ];
}
