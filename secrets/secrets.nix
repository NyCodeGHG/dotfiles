let
  users = {
    marie-catcafe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz marie@catcafe";
    marie-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp";
  };
  systems = {
    artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis";
    delphi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3 root@delphi";
    wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpKCSJGPFfckgr1/X1Rv7jeOe9E8tYmP1iqogzSXF+u";
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
  "restic-repo.age".publicKeys = withSystems systems.artemis;
  "b2-restic.age".publicKeys = withSystems systems.artemis;
  "discord-webhook.age".publicKeys = withSystems systems.artemis;
  "synapse-sso-config.age".publicKeys = withSystems systems.artemis;
  "delphi-wg-privatekey.age".publicKeys = withSystems systems.delphi;
  "artemis-wg-privatekey.age".publicKeys = withSystems systems.artemis;
  "pgrok-client-secret.age".publicKeys = withSystems systems.artemis;
  "paperless-env.age".publicKeys = withSystems systems.delphi;
  "curseforge-api-key.age".publicKeys = withSystems systems.delphi;
  "renovate-env.age".publicKeys = withSystems systems.artemis;
  "forgejo-runner-token.age".publicKeys = withSystems systems.artemis;
  "minio.age".publicKeys = withSystems systems.delphi;
  "turn-secret.age".publicKeys = withSystems systems.delphi;
  "turn-secret-synapse-config.age".publicKeys = withSystems systems.artemis;

  "git-email.age".publicKeys = withSystems systems.wsl;

  "../hosts/artemis/dn42/peers/emma/wg-private.age".publicKeys = withSystems systems.artemis;
  "../hosts/artemis/dn42/peers/kioubit/wg-private.age".publicKeys = withSystems systems.artemis;
  "../hosts/artemis/dn42/peers/spectre-net/wg-private.age".publicKeys = withSystems systems.artemis;
}
