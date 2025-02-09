{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings = {
      max_wal_senders = 3;
      wal_level = "replica";
    };
  };
}
