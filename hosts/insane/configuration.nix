{ pkgs, modulesPath, self, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ../../profiles/locale.nix
    ../../profiles/openssh.nix
    ../../profiles/nix-config.nix
    ../../profiles/locale.nix
    ./networking.nix
    ./hardware.nix
    # ./waydroid.nix
    ./scanservjs.nix
    self.inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  environment.systemPackages = with pkgs; [ sbctl ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  security.sudo.wheelNeedsPassword = false;

  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      default = true;
      locations."/" = {
        root = ./web;
        index = "image.jpg";
        tryFiles = "$uri $uri/ =404";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
