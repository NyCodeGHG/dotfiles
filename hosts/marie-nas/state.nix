{
  lib,
  config,
  inputs,
  ...
}:
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
          {
            directory = "/home/marie";
            user = "marie";
            group = "users";
            mode = "0700";
          }
          "/var/db/sudo"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
          "/var/lib/systemd"
          {
            directory = "/var/lib/tailscale";
            mode = "0700";
          }
          "/var/log"
          "/var/lib/samba"
          "/var/cache/samba"
          "/var/lib/acme"
          {
            directory = "/var/lib/jellyfin";
            user = "jellyfin";
            group = "media";
            mode = "0700";
          }
          {
            directory = "/var/lib/transmission";
            user = "transmission";
            group = "media";
            mode = "0750";
          }
          {
            directory = "/var/lib/private/prowlarr";
            user = "prowlarr";
            group = "prowlarr";
          }
          {
            directory = "/var/lib/private/jellyseerr";
            user = "jellyseerr";
            group = "jellyseerr";
          }
          {
            directory = "/var/lib/private/bitmagnet";
            user = "bitmagnet";
            group = "bitmagnet";
          }
          {
            directory = "/var/lib/sonarr";
            user = "sonarr";
            group = "sonarr";
          }
          {
            directory = "/var/lib/hass";
            user = "hass";
            group = "hass";
          }
          {
            directory = "/var/lib/mosquitto";
            user = "mosquitto";
            group = "mosquitto";
          }
          {
            directory = "/var/lib/zigbee2mqtt";
            user = "zigbee2mqtt";
            group = "zigbee2mqtt";
          }
          {
            directory = "/var/lib/redis-oauth2-proxy";
            user = "oauth2-proxy";
            group = "oauth2-proxy";
          }
          {
            directory = "/var/lib/home-assistant-matter-hub";
            mode = "0700";
          }
          "/var/lib/minecraft"
          {
            directory = "/var/lib/private/factorio";
            mode = "0770";
          }
        ];
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
          {
            file = "/etc/NIXOS";
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            mode = "0700";
            inInitrd = true;
            how = "symlink";
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            inInitrd = true;
            how = "symlink";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            mode = "0700";
            inInitrd = true;
            how = "symlink";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            inInitrd = true;
            how = "symlink";
          }
          {
            file = "/etc/zfs/zpool.cache";
            inInitrd = true;
            how = "symlink";
          }
        ];
      };
    };

    systemd.tmpfiles.settings.preservation = {
      "/state/var/lib/private".d.mode = "0700";
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    boot.initrd.systemd = {
      storePaths = [ config.boot.zfs.package ];
      services.rollback-fs = {
        wantedBy = [ "initrd.target" ];
        after = [ "zfs-import-zroot.service" ];
        before = [
          "initrd-root-fs.target"
          "sysroot.mount"
        ];
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
