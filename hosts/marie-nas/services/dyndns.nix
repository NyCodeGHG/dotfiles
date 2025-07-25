{ 
  config,
  ...
}:
{
  uwumarie.cloudflare-dyndns = {
    enable = true;
    zoneId = "aa9307069abf9520bed8b74c8b2d9f73";
    name = "marie-nas-v6.marie.cologne";
    tokenFile = config.age.secrets.cloudflare-token.path;
  };
  age.secrets.cloudflare-token.file = ../secrets/cloudflare-token.age;
}
