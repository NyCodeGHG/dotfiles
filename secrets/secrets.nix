let
  users = {
    marie-catcafe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz marie@catcafe";
  };
  systems = {
    artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis";
  };
  allUsers = builtins.attrValues users;
  allSystems = builtins.attrValues systems;
in
{
  "cloudflare-api-key.age".publicKeys = allUsers ++ allSystems;
  "authentik-secrets.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "miniflux-credentials.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "grafana-oauth-client-secret.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "coder-oauth.age".publicKeys = [ users.marie-catcafe systems.artemis ];
}
