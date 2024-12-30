{ config, pkgs, lib, ... }:
let
  inherit (pkgs) pgbackrest;
  configFormat = pkgs.formats.ini { };
  backupPath = "/mnt/pgbackrest";
  pgBackrestConfig = {
    artemis = {
      pg1-path = config.services.postgresql.dataDir;
    };
    global = {
      repo1-path = backupPath;
      repo1-retention-full = 4;
      repo1-retention-diff = 6;
      repo1-bundle = "y";
      repo1-block = "y";
      start-fast = "y";
      process-max = 3;
      compress-type = "zst";
    };
  };
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings = {
      archive_command = "${lib.getExe pgbackrest} --stanza=artemis archive-push %p";
      archive_mode = true;
      max_wal_senders = 3;
      wal_level = "replica";
    };
  };
  systemd.services.postgresql.serviceConfig.ReadWritePaths = [
    "/mnt/pgbackrest"
  ];
  environment.etc = {
    "pgbackrest/pgbackrest.conf".source = configFormat.generate "pgbackrest.conf" pgBackrestConfig;
    "pgbackrest/conf.d/encryption.conf".source = config.age.secrets.pgbackrest.path;
  };

  age.secrets.pgbackrest = {
    file = ./secrets/pgbackrest.age;
    owner = "postgres";
    group = "postgres";
  };

  systemd.tmpfiles.settings."10-pgbackrest" = {
    ${backupPath}.d = {
      group = "postgres";
      mode = "0750";
      user = "postgres";
    };
  };

  environment.systemPackages = [ pgbackrest ];

  systemd.services = {
    "pgbackrest-init@" = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        UMask = "077";
        ExecStart = lib.concatStringsSep " " ([
          (lib.getExe pgbackrest)
          "--log-level-console=info"
          "--stanza=%i"
          "stanza-create"
        ]);
        RemainAfterExit = true;
      };
      restartTriggers = [
        config.environment.etc."pgbackrest/pgbackrest.conf".source
        config.environment.etc."pgbackrest/conf.d/encryption.conf".source
      ];
    };
    "pgbackrest-check@" = {
      after = [ "postgresql.service" "pgbackrest-init@%i.service" ];
      requires = [ "postgresql.service" "pgbackrest-init@%i.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        UMask = "077";
        ExecStart = lib.concatStringsSep " " ([
          (lib.getExe pgbackrest)
          "--log-level-console=info"
          "--stanza=%i"
          "check"
        ]);
        RemainAfterExit = true;
      };
      restartTriggers = [
        config.environment.etc."pgbackrest/pgbackrest.conf".source
        config.environment.etc."pgbackrest/conf.d/encryption.conf".source
      ];
    };

    "pgbackrest-backup-full@" = {
      after = [ "postgresql.service" "pgbackrest-init@%i.service" "pgbackrest-check@%i.service" ];
      requires = [ "postgresql.service" "pgbackrest-init@%i.service" "pgbackrest-check@%i.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        Restart = "on-failure";
        UMask = "077";
        RemainAfterExit = true;
        ExecStart = lib.concatStringsSep " " ([
          (lib.getExe pgbackrest)
          "--log-level-console=info"
          "--stanza=%i"
          "--type=full"
          "backup"
        ]);
      };
    };

    "pgbackrest-backup-diff@" = {
      after = [ "postgresql.service" "pgbackrest-init@%i.service" "pgbackrest-check@%i.service" "pgbackrest-backup-full@%i.service" ];
      requires = [ "postgresql.service" "pgbackrest-init@%i.service" "pgbackrest-check@%i.service" "pgbackrest-backup-full@%i.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        Restart = "on-failure";
        UMask = "077";
        ExecStart = lib.concatStringsSep " " ([
          (lib.getExe pgbackrest)
          "--log-level-console=info"
          "--stanza=%i"
          "--type=diff"
          "backup"
        ]);
      };
    };
    "pgbackrest-init@artemis" = {
      wantedBy = [ "multi-user.target" ];
      overrideStrategy = "asDropin";
    };
    "pgbackrest-check@artemis" = {
      wantedBy = [ "multi-user.target" ];
      overrideStrategy = "asDropin";
    };
    "pgbackrest-backup-full@artemis" = {
      startAt = "Mon";
      overrideStrategy = "asDropin";
    };
    "pgbackrest-backup-diff@artemis" = {
      startAt = "Tue,Wed,Thu,Fri,Sat,Sun";
      overrideStrategy = "asDropin";
    };
  };
}

