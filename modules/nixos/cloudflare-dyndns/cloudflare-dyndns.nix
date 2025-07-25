{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.uwumarie.cloudflare-dyndns;
  python = pkgs.python3.withPackages (ps: with ps; [ netifaces cloudflare ]);
in
{
  options.uwumarie.cloudflare-dyndns = {
    enable = lib.mkEnableOption "Cloudflare DynDNS";
    zoneId = lib.mkOption {
      type = lib.types.str;
      description = "Cloudflare Zone ID";
    };
    name = lib.mkOption {
      type = lib.types.str;
      description = "DNS record name to create";
    };
    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the cloudflare token";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.cloudflare-dyndns = {
      description = "Cloudflare DynDNS";
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        ProtectSystem = "full";
        LoadCredential = "cloudflare-token:${cfg.tokenFile}";
        ExecStart = "${lib.getExe python} ${./cloudflare-dyndns.py}";
      };
      startAt = "*:0/5:30";
      environment = {
        CLOUDFLARE_TOKEN_FILE = "%d/cloudflare-token";
        CLOUDFLARE_ZONE_ID = cfg.zoneId;
        CLOUDFLARE_RECORD_NAME = cfg.name;
      };
    };
  };
}
