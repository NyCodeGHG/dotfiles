{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

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
      # Desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
    ];
  };

  services.openssh.settings.PermitRootLogin = "prohibit-password";

  system.stateVersion = "23.11";
}
