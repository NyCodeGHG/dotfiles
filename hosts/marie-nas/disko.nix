{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S466NB0K428706Z";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
                settings = {
                  allowDiscards = true;
                  keyFile = "/encryption-keys/root.key";
                };
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      wd-red-plus-a = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7JPDSJN";
        content = {
          type = "luks";
          name = "wd-red-plus-a";
          settings = {
            allowDiscards = true;
            keyFile = "/encryption-keys/wd-red-plus-a.key";
          };
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
      };
      wd-red-plus-b = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7JLAHXN";
        content = {
          type = "luks";
          name = "wd-red-plus-b";
          settings = {
            allowDiscards = true;
            keyFile = "/encryption-keys/wd-red-plus-b.key";
          };
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
      };
    };
    zpool =
      let
        options = {
          acltype = "posixacl";
          compression = "zstd";
          mountpoint = "none";
          xattr = "sa";
          dnodesize = "auto";
          atime = "off";
        };
      in
      {
        zroot = {
          type = "zpool";
          rootFsOptions = options;
          options.ashift = "12";
          postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/local/root@blank$' || zfs snapshot zroot/local/root@blank";

          datasets = {
            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options = {
                mountpoint = "legacy";
              };
            };
            "local/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                mountpoint = "legacy";
              };
            };
            "data/state" = {
              type = "zfs_fs";
              mountpoint = "/state";
              options = {
                mountpoint = "legacy";
              };
            };
            "data/postgres/data" = {
              type = "zfs_fs";
              mountpoint = "/var/lib/postgresql";
              options = {
                mountpoint = "legacy";
              };
            };
            "data/postgres/wal-17" = {
              type = "zfs_fs";
              mountpoint = "/var/lib/postgresql/17/pg_wal";
              options = {
                mountpoint = "legacy";
              };
            };
          };
        };
        tank = {
          type = "zpool";
          mode = "mirror";
          rootFsOptions = options;
          options.ashift = "12";

          datasets = {
            "data/shares" = {
              type = "zfs_fs";
              mountpoint = "/srv/shares";
              options = {
                mountpoint = "legacy";
              };
            };
            "data/shares/media" = {
              type = "zfs_fs";
              mountpoint = "/srv/shares/media";
              options = {
                recordsize = "1M";
                mountpoint = "legacy";
              };
            };
            "data/shares/marie" = {
              type = "zfs_fs";
              mountpoint = "/srv/shares/marie";
              options = {
                mountpoint = "legacy";
              };
            };
            "data/shares/lena" = {
              type = "zfs_fs";
              mountpoint = "/srv/shares/lena";
              options = {
                mountpoint = "legacy";
              };
            };
            "data/shares/public" = {
              type = "zfs_fs";
              mountpoint = "/srv/shares/public";
              options = {
                mountpoint = "legacy";
                quota = "200G";
              };
            };
            "data/restic/marie" = {
              type = "zfs_fs";
              mountpoint = "/srv/restic/marie";
              options = {
                mountpoint = "legacy";
              };
            };
          };
        };
      };
  };
}
