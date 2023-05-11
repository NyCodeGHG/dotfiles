let
  users = {
    marie-catcafe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz marie@catcafe";
  };
  systems = {
    artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOTrdHkjvxDWvcEmkvKiXJdQB6Oq65N9hofEWnuQmIl root@artemis";
  };
  allUsers = builtins.attrValues users;
  allSystems = builtins.attrValues systems;
in
{
  "cloudflare-api-key.age".publicKeys = allUsers ++ allSystems;
  "authentik-secrets.age".publicKeys = [ users.marie-catcafe systems.artemis ];
}
