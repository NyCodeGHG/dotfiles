let
  users = {
    marie-catcafe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz marie@catcafe";
  };
  systems = {
    artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis";
    delphi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3 root@delphi";
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
  "gitlab-root-password.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "gitlab-secret.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "gitlab-otp-secret.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "gitlab-jws-key.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "gitlab-db-secret.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "gitlab-github-client-secret.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "restic-repo.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "b2-restic.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "discord-webhook.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "synapse-sso-config.age".publicKeys = [ users.marie-catcafe systems.artemis ];
  "delphi-wg-privatekey.age".publicKeys = [ users.marie-catcafe systems.delphi ];
}
