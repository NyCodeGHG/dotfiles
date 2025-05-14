{
  lib,
  config,
  ...
}:
let
  cfg = config.services.anubis;
  enabledInstances = lib.filterAttrs (_: conf: conf.enable) cfg.instances;
  hasInstances = (enabledInstances != { });
in
{
  config = lib.mkIf hasInstances {
    users.users.nginx.extraGroups = [
      config.users.groups.anubis.name
    ];

    services.anubis.defaultOptions.settings = {
      SERVE_ROBOTS_TXT = true;
    };
  };
}
