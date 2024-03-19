{ config, lib, pkgs, ... }:

lib.mkIf config.uwumarie.profiles.users.marie {
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.mkIf config.services.openssh.enable [
      # Desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
      # Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz"
    ];
  };
}
