{ config, lib, ... }:
lib.mkIf config.uwumarie.profiles.unlock-ssh-keys {
  programs.unlock-ssh-keys = {
    enable = true;
    settings.folder = "SSH Keys";
  };
}
