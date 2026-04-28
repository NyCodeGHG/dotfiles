{ pkgs, ... }:
{
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    preseed = {
      config."core.https_address" = ":8443";
      storage_pools = [
        {
          config = {
            source = "/var/lib/incus/storage-pools/default";
          };
          driver = "dir";
          name = "default";
        }
      ];
      profiles = [
        {
          config = {
            "security.secureboot" = false;
          };
          devices = {
            eth0 = {
              name = "eth0";
              nictype = "bridged";
              parent = "br0";
              type = "nic";
            };
            root = {
              path = "/";
              size = "40GiB";
              pool = "default";
              type = "disk";
            };
          };
          project = "default";
          name = "default";
        }
      ];
    };
  };

  users.users = {
    marie.extraGroups = [ "incus-admin" ];
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];

  nixpkgs.config.permittedInsecurePackages = [
    "minio-2025-10-15T17-29-55Z"
  ];
}
