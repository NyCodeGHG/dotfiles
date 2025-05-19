{ config, lib, pkgs, ... }:

lib.mkIf config.uwumarie.profiles.users.marie {
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ] ++
      lib.optional config.programs.gamemode.enable "gamemode" ++
      lib.optional config.virtualisation.libvirtd.enable "libvirtd" ++
      lib.optional config.services.pipewire.enable "pipewire" ++
      lib.optional config.programs.adb.enable "adbusers";
    openssh.authorizedKeys.keys = lib.mkIf config.services.openssh.enable [
      # Desktop old
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
      # Desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdNaJgKxA021pqrbkoMiP2a9buYZUXfG5q01y2h8YOa"
      # Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz"
    ];
  };
}
