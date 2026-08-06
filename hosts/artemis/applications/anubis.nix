{
  config,
  ...
}:
{
  users.users.nginx.extraGroups = [
    config.users.groups.anubis.name
  ];

  services.anubis.defaultOptions.settings = {
    SERVE_ROBOTS_TXT = true;
  };
}
