{ config, pkgs, lib, inputs, ... }:
let
  activateMaintenanceMode = pkgs.writeScript "activate-maintenance-mode.rb" ''
    ::Gitlab::CurrentSettings.update!(maintenance_mode: true)
    ::Gitlab::CurrentSettings.update!(maintenance_mode_message: "Backup in progress")
  '';
  deactivateMaintenanceMode = pkgs.writeScript "deactivate-maintenance-mode.rb" ''
    ::Gitlab::CurrentSettings.update!(maintenance_mode: false)
  '';
in
{
  services.restic.backups."gitlab" = {
    repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
    user = "root";
    timerConfig = {
      OnCalendar = "1:00";
      Persistent = true;
    };
    environmentFile = config.age.secrets.b2-restic.path;
    pruneOpts = [
      "--keep-daily 2"
      "--keep-weekly 2"
      "--keep-monthly 2"
      "--keep-yearly 75"
      "--tag gitlab"
      "--host ${config.networking.hostName}"
    ];
    extraBackupArgs = [
      "--tag gitlab"
    ];
    backupPrepareCommand = ''
      ${pkgs.sudo}/bin/sudo --user=gitlab /run/current-system/sw/bin/gitlab-rake gitlab:backup:create "SKIP=tar,db,repositories" RAILS_ENV=production
    '';
    backupCleanupCommand = ''
      rm -r /var/gitlab/state/backup/
    '';
    paths = [
      "/var/gitlab/state/backup"
    ];
    passwordFile = config.age.secrets.restic-repo.path;
  };
  services.restic.backups."gitlab-repositories" = {
    repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
    user = "root";
    timerConfig = {
      OnCalendar = "1:30";
      Persistent = true;
    };
    environmentFile = config.age.secrets.b2-restic.path;
    pruneOpts = [
      "--keep-daily 2"
      "--keep-weekly 2"
      "--keep-monthly 2"
      "--keep-yearly 75"
      "--tag gitlab-repositories"
      "--host ${config.networking.hostName}"
    ];
    extraBackupArgs = [
      "--tag gitlab-repositories"
    ];
    paths = [
      "/var/gitlab/state/repositories/"
    ];
    backupPrepareCommand = ''
      ${pkgs.sudo}/bin/sudo --user=gitlab /run/current-system/sw/bin/gitlab-rails runner -e production ${activateMaintenanceMode}
    '';
    backupCleanupCommand = ''
      ${pkgs.sudo}/bin/sudo --user=gitlab /run/current-system/sw/bin/gitlab-rails runner -e production ${deactivateMaintenanceMode}
    '';
    passwordFile = config.age.secrets.restic-repo.path;
  };
  age.secrets.restic-repo.file = "${inputs.self}/secrets/restic-repo.age";
  age.secrets.b2-restic.file = "${inputs.self}/secrets/b2-restic.age";
  age.secrets.discord-webhook.file = "${inputs.self}/secrets/discord-webhook.age";
}
