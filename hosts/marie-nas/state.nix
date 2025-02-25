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
          { directory = "/etc/secrets/initrd"; inInitrd = true; }
          "/var/lib/samba"
          "/var/cache/samba"
          "/var/lib/acme"
        ];
        files = [
          { file = "/etc/machine-id"; inInitrd = true; how = "symlink"; }
          { file = "/etc/NIXOS"; inInitrd = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_ed25519_key"; mode = "0700"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_ed25519_key.pub"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_rsa_key"; mode = "0700"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_rsa_key.pub"; inInitrd = true; configureParent = true; how = "symlink"; }
          { file = "/etc/zfs/zpool.cache"; inInitrd = true; how = "symlink"; }
        ];
      };
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [ "" "/state/etc/machine-id" ];
      serviceConfig.ExecStart = [ "" "systemd-machine-id-setup --commit --root /state" ];
    };

    boot.initrd.systemd = {
      storePaths = [ config.boot.zfs.package ];
      services.rollback-fs = {
        enable = false;
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
