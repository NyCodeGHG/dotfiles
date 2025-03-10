{ pkgs, config, lib, ... }:
{
  age.secrets.restic-password = {
    file = ./secrets/restic-password.age;
    owner = "marie";
    group = "users";
  };
  systemd.services.backup = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      PrivateMounts = true;
      SystemCallFilter = [ "@system-service" "@mount" ];
    };
    environment = {
      RESTIC_REPOSITORY = "sftp:marie@marie-nas.fritz.box:/srv/restic/marie";
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-password.path;
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
      HOME = "/home/marie";
    };
    path = with pkgs; [ restic util-linux btrfs-progs config.programs.ssh.package config.security.sudo.package ];
    script = ''
      set -euo pipefail
      SNAPSHOT_NAME="@restic-$(date "+%F_%k-%M-%S")"
      btrfs subvolume snapshot /home "/home/$SNAPSHOT_NAME"

      function cleanup() {
        mount -t btrfs -o subvol=home ${config.fileSystems."/home".device} /home
        btrfs subvolume delete "/home/$SNAPSHOT_NAME"
      }

      trap cleanup EXIT

      umount /home
      mount -t btrfs -o subvol="/home/$SNAPSHOT_NAME" '${config.fileSystems."/home".device}' /home

      sudo \
        --user=marie \
        --preserve-env=RESTIC_REPOSITORY,RESTIC_PASSWORD_FILE,SSH_AUTH_SOCK \
          restic backup \
            --exclude-caches \
            --exclude-file "${./scripts/restic-excludes.txt}" \
            --tag home \
            --one-file-system \
            "$HOME"
    '';
  };
}
