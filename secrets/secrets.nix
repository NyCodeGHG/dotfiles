let
  users = {
    marie-catcafe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz marie@catcafe";
    marie-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp";
  };
  systems = {
    artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis";
    delphi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3 root@delphi";
  };
  allUsers = builtins.attrValues users;
  allSystems = builtins.attrValues systems;
  withSystems = systems: allUsers ++ (if builtins.isList systems then systems else [ systems ]);
in
{
  "cloudflare-api-key.age".publicKeys = withSystems allSystems;
  "authentik-secrets.age".publicKeys = withSystems systems.artemis;
  "miniflux-credentials.age".publicKeys = withSystems systems.artemis;
  "grafana-oauth-client-secret.age".publicKeys = withSystems systems.artemis;
  "coder-oauth.age".publicKeys = withSystems systems.artemis;
  "gitlab-root-password.age".publicKeys = withSystems systems.artemis;
  "gitlab-secret.age".publicKeys = withSystems systems.artemis;
  "gitlab-otp-secret.age".publicKeys = withSystems systems.artemis;
  "gitlab-jws-key.age".publicKeys = withSystems systems.artemis;
  "gitlab-db-secret.age".publicKeys = withSystems systems.artemis;
  "gitlab-github-client-secret.age".publicKeys = withSystems systems.artemis;
  "restic-repo.age".publicKeys = withSystems systems.artemis;
  "b2-restic.age".publicKeys = withSystems systems.artemis;
  "discord-webhook.age".publicKeys = withSystems systems.artemis;
  "synapse-sso-config.age".publicKeys = withSystems systems.artemis;
  "delphi-wg-privatekey.age".publicKeys = withSystems systems.delphi;
  "pgrok-client-secret.age".publicKeys = withSystems systems.artemis;
  "paperless-env.age".publicKeys = withSystems systems.delphi;
}
