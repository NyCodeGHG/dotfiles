{ config, ... }:
{
  systemd.services.ssh-keygen-initrd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    unitConfig = {
      ConditionFileNotEmpty = [
        "|!/etc/secrets/initrd/ssh_host_rsa_key"
        "|!/etc/secrets/initrd/ssh_host_ed25519_key"
      ];
    };
    path = [ config.services.openssh.package ];
    script = ''
      if [[ ! -s /etc/secrets/initrd/ssh_host_rsa_key ]]; then
        ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
      fi
      if [[ ! -s /etc/secrets/initrd/ssh_host_ed25519_key ]]; then
        ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
      fi
    '';
  };
  systemd.tmpfiles.settings."initrd-host-keys"."/etc/secrets/initrd".d = {
    group = "root";
    mode = "0755";
    user = "root";
  };
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.marie.openssh.authorizedKeys.keys;
      hostKeys = [
        "/etc/secrets/initrd/ssh_host_rsa_key"
        "/etc/secrets/initrd/ssh_host_ed25519_key"
      ];
      port = 2222;
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
          KeepConfiguration = "yes";
        };
      };
    };
  };
}
