{ pkgs, modulesPath, config, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./hardware.nix
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

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks = {
      "10-ethernet" = {
        matchConfig.Type = [ "ether" ];
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          KeepConfiguration = "yes";
        };
      };
    };
  };

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

  uwumarie.cachix-upload = {
    enable = true;
    cache = "uwumarie";
    packages = [ "mongodb" ];
    cachixTokenFile = config.age.secrets.cachix-auth-token.path;
  };
  age.secrets.cachix-auth-token.file = ./cachix-auth-token.age;
}
