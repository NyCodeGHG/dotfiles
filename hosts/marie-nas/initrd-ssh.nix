{ config, ... }:
{
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.marie.openssh.authorizedKeys.keys;
      hostKeys = [
        "/state/secrets/initrd/ssh_host_rsa_key"
        "/state/secrets/initrd/ssh_host_ed25519_key"
      ];
    };
  };
  boot.initrd.systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        dhcpV4Config = {
          Hostname = "${config.networking.hostName}-initrd";
        };
      };
    };
  };
}
