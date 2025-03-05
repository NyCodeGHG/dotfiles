{ lib, config, inputs, ... }:
{
  imports = [
    inputs.preservation.nixosModules.default
  ];
  options.uwumarie.state.enable = lib.mkEnableOption "state" // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.state.enable {
    users.mutableUsers = false;
    preservation = {
      enable = true;
      preserveAt."/state" = {
        directories = [
          { directory = "/home/marie"; user = "marie"; group = "users"; }
          "/var/db/sudo"
          { directory = "/var/lib/nixos"; inInitrd = true; }
          "/var/lib/systemd"
          "/var/lib/tailscale"
          "/var/log"
          "/var/lib/samba"
          "/var/cache/samba"
          "/var/lib/acme"
        ];
        files = [
          { file = "/etc/machine-id"; inInitrd = true; }
          { file = "/etc/NIXOS"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_ed25519_key"; mode = "0700"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_ed25519_key.pub"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_rsa_key"; mode = "0700"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_rsa_key.pub"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/zfs/zpool.cache"; inInitrd = true; configureParent = true; how = "symlink"; }
        ];
      };
    };

    boot.initrd.systemd = {
      storePaths = [ config.boot.zfs.package ];
      services.rollback-fs = {
        wantedBy = [ "initrd.target" ];
        after = [ "zfs-import-zroot.service" ];
        before = [ "initrd-root-fs.target" "sysroot.mount" ];
        description = "Rollback root filesystem";
        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe config.boot.zfs.package} rollback -r zroot/local/root@blank";
        };
      };
    };
  };
}
