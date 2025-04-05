{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    dataDir = "/var/lib/postgresql/17";
    settings = {
      # zfs takes care of that
      full_page_writes = "off";

      # pgtune
      max_connections = "100";
      shared_buffers = "2GB";
      effective_cache_size = "6GB";
      maintenance_work_mem = "512MB";
      checkpoint_completion_target = "0.9";
      wal_buffers = "16MB";
      default_statistics_target = "100";
      random_page_cost = "1.1";
      effective_io_concurrency = "200";
      work_mem = "5242kB";
      huge_pages = "off";
      min_wal_size = "1GB";
      max_wal_size = "1GB";

      timezone = "UTC";
    };
  };
  fileSystems = {
    "/var/lib/postgresql" = {
      device = "zroot/data/postgres/data";
      fsType = "zfs";
    };
    "/var/lib/postgresql/17/pg_wal" = {
      device = "zroot/data/postgres/wal-17";
      fsType = "zfs";
    };
  };
}
