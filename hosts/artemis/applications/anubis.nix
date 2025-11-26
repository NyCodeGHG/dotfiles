{
  config,
  pkgs,
  ...
}:
let
  configFile = (pkgs.formats.yaml { }).generate "anubis-policy-config.yaml" {
    bots = [
      { import = "(data)/meta/default-config.yaml"; }
      {
        name = "forgejo-runner";
        path_regex = "^/api/actions/(?:runner.v1.RunnerService|ping.v1.PingService)/.*$";
        action = "ALLOW";
      }
      {
        name = "blackbox-exporter";
        user_agent_regex = "^Blackbox Exporter\/\d+\.\d+\.\d+$";
        action = "ALLOW";
      }
    ];
  };
in
{
  users.users.nginx.extraGroups = [
    config.users.groups.anubis.name
  ];

  services.anubis.defaultOptions.settings = {
    SERVE_ROBOTS_TXT = true;
    POLICY_FNAME = toString configFile;
  };
}
