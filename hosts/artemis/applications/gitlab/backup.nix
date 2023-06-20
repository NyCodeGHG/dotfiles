{ config, pkgs, lib, inputs, ... }:
let
  mkResticService = service: {
    serviceConfig = {
      User = config.services.gitlab.user;
      Type = "oneshot";
    };
    environment = {
      RESTIC_REPOSITORY = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
      XDG_CACHE_DIR = "/var/cache/";
    };
  } // service;
  resticForget = tag: ''
    ${pkgs.restic}/bin/restic forget \
      --tag "${tag}" \
      --host ${config.networking.hostName} \
      --keep-daily 2 \
      --keep-weekly 2 \
      --keep-monthly 2 \
      --keep-yearly 75
  '';
  mkGitLabBackup =
    { tag
    , skip ? ""
    , conflicts ? [ ]
    , after ? [ ]
    , script ? ''
        set -eo pipefail
        ${pkgs.sudo}/bin/sudo -u gitlab -H /run/current-system/sw/bin/gitlab-rake gitlab:backup:create "SKIP=${skip}" RAILS_ENV=production
        ${pkgs.restic}/bin/restic backup \
          --tag "${tag}" \
          /var/gitlab/state/backup/
      
        rm -r /var/gitlab/state/backup/
        ${resticForget tag}
      ''
    ,
    }: mkResticService {
      serviceConfig = {
        EnvironmentFile = config.age.secrets.b2-restic.path;
      };
      inherit conflicts script after;
      onFailure = [ "restic-backup-gitlab-notification@%n.service" ];
      onSuccess = [ "restic-backup-gitlab-notification-success.service" ];
    };
  mkNotifications = tag: {
    "restic-backup-${tag}-notification@" =
      let
        script = pkgs.writeScript "notification" ''
          UNIT=$1
          HOST=$2

          UNITSTATUS=$(systemctl status $UNIT)

          ${pkgs.discord-sh}/bin/discord.sh \
            --username "GitLab Restic Backup" \
            --avatar "https://restic.readthedocs.io/en/stable/_static/logo.png" \
            --text "<@449893028266770432>" \
            --title ":x: GitLab Backup Failed!" \
            --color "0xFF0000" \
            --timestamp \
            --field "Unit;$UNIT" \
            --description "$(echo $UNITSTATUS | ${pkgs.jq}/bin/jq -Rs . | cut -c 2- | ${pkgs.util-linux}/bin/rev | cut -c 2- | ${pkgs.util-linux}/bin/rev)"
        '';
      in
      {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${script} %I %H";
          EnvironmentFile = config.age.secrets.discord-webhook.path;
        };
        unitConfig = {
          Description = "Restic Backup ${tag} Notification";
          After = "network.target";
        };
      };

    "restic-backup-${tag}-notification-success" = mkResticService
      {
        serviceConfig = {
          EnvironmentFile = [ config.age.secrets.b2-restic.path config.age.secrets.discord-webhook.path ];
        };
        unitConfig = {
          Description = "Restic Backup Success gitlab Notification";
          After = "network.target";
        };
        script =
          let
            numfmt = value: ''numfmt --to=iec-i --suffix=B --format="%9.2f" ${value}'';
          in
          ''
            set -eo pipefail

            STATS=$(${pkgs.restic}/bin/restic stats \
              --tag "${tag}" \
              --host ${config.networking.hostName} \
              --mode raw-data \
              --json)

            TOTAL_SIZE=$(echo $STATS | ${pkgs.jq}/bin/jq ".total_size")
            TOTAL_UNCOMPRESSED_SIZE=$(echo $STATS | ${pkgs.jq}/bin/jq ".total_uncompressed_size")
            COMPRESSION_RATIO=$(echo $STATS | ${pkgs.jq}/bin/jq ".compression_ratio")
            COMPRESSION_SPACE_SAVING=$(echo $STATS | ${pkgs.jq}/bin/jq ".compression_space_saving")
            TOTAL_BLOB_COUNT=$(echo $STATS | ${pkgs.jq}/bin/jq ".total_blob_count")
            SNAPSHOTS_COUNT=$(echo $STATS | ${pkgs.jq}/bin/jq ".snapshots_count")

            export LC_NUMERIC="en_US.UTF-8"
            ${pkgs.discord-sh}/bin/discord.sh \
              --username "GitLab Restic Backup" \
              --avatar "https://restic.readthedocs.io/en/stable/_static/logo.png" \
              --title ":white_check_mark: Backup created!" \
              --color "0x00FF00" \
              --timestamp \
              --field "Total Size;$(${numfmt "$TOTAL_SIZE"})" \
              --field "Total Uncompressed Size;$(${numfmt "$TOTAL_UNCOMPRESSED_SIZE"})" \
              --field "Compression Ratio;$(printf "%8.2f" "$COMPRESSION_RATIO")" \
              --field "Compression Space Saving;$(printf "%8.2f" "$COMPRESSION_SPACE_SAVING")%" \
              --field "Total Blobs;$TOTAL_BLOB_COUNT" \
              --field "Snapshots;$SNAPSHOTS_COUNT" \
              --description "Backup Job: ${tag}"
          '';
      };
  };
in
{
  systemd.timers."restic-backup-gitlab" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-backup-gitlab.service" "restic-backup-gitlab-repositories.service" ];
    timerConfig = {
      OnCalendar = "01:00";
    };
  };

  systemd.services = lib.mkMerge [
    (mkNotifications "gitlab-repositories")
    (mkNotifications "gitlab")
    {
      "restic-backup-gitlab" = mkGitLabBackup {
        tag = "gitlab";
        skip = "db,tar,repositories";
      };
      "restic-backup-gitlab-repositories" = mkGitLabBackup rec {
        tag = "gitlab-repositories";
        conflicts = [ "gitaly.service" ];
        after = [ "restic-backup-gitlab.service" ];
        script = ''
          set -eo pipefail
          ${pkgs.restic}/bin/restic backup \
            --tag "${tag}" \
            /var/gitlab/state/repositories

          ${resticForget tag}
        '';
      };
    }
  ];

  age.secrets.restic-repo.file = "${inputs.self}/secrets/restic-repo.age";
  age.secrets.b2-restic.file = "${inputs.self}/secrets/b2-restic.age";

  age.secrets.discord-webhook.file = "${inputs.self}/secrets/discord-webhook.age";
}
