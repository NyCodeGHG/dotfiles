{
  config,
  lib,
  ...
}:

lib.mkIf config.uwumarie.profiles.users.marie {
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ]
    ++ lib.optional config.programs.gamemode.enable "gamemode"
    ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ lib.optional config.virtualisation.podman.enable "podman"
    ++ lib.optional config.services.pipewire.enable "pipewire"
    ++ lib.optional config.programs.wireshark.enable "wireshark";
    openssh.authorizedKeys.keys = lib.mkIf config.services.openssh.enable (import ../../../keys/ssh);
  };
}
