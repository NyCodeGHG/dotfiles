{ pkgs, modulesPath, config, inputs, ... }:
{
  imports = with inputs; [
    agenix.nixosModules.default
    preservation.nixosModules.default
    ../../config/nixos/system/acme.nix
    (modulesPath + "/profiles/minimal.nix")
    ./forgejo-runner.nix
    ./state.nix
    ./hardware.nix
  ];

  boot.supportedFilesystems.bcachefs = true;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_6_12;

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
    };
  };

  services.tailscale.enable = true;

  services.resolved.enable = true;

  users.users.root = {
    openssh.authorizedKeys.keys = [
      # Warpgate public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFPCqSH26mf3vHii7DUtHRZ33OhSVYpjUMmbTDReS+s"
      # Marie desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdNaJgKxA021pqrbkoMiP2a9buYZUXfG5q01y2h8YOa"
    ];
  };

  users.users.builder = {
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      # Warpgate public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFPCqSH26mf3vHii7DUtHRZ33OhSVYpjUMmbTDReS+s"
      # Marie desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
      # root@marie-desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKl1gOAizi410fKbP0wP6+XJMAk+JDx+mLp2amPKKQPY"
    ];
    group = "builder";
    shell = pkgs.bashInteractive;
  };
  users.groups.builder = { };

  nix.settings.trusted-users = [ "builder" ];

  services.openssh.settings.PermitRootLogin = "prohibit-password";

  system.stateVersion = "24.11";

  environment.systemPackages = with pkgs; [ 
    rsync
    nix-output-monitor
    tmux
    github-cli
    nixpkgs-review
  ];
}
