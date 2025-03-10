let
  marie-desktop-wsl = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"];
  marie-desktop = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdNaJgKxA021pqrbkoMiP2a9buYZUXfG5q01y2h8YOa"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA56+5iSfyhYaTU3jc4Hl6G2qqHOUG9SMymPr5dfwbZf"
  ];
  artemis = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis"];
  delphi = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3 root@delphi"];
  wsl = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpKCSJGPFfckgr1/X1Rv7jeOe9E8tYmP1iqogzSXF+u"];
  gitlabber = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFxL7AqowWxKzJqrj8Mr2MDF3NDbyExAPwKjohoCx/t"];
  marie-nas = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwvQy3cK9gGwFEf5UGCxQ61j8Kv30JDAZ39FOtKkrCQ"];
  marie-desktop-host = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSpnu/du04AEB2LuwIHJU5CZwBFsMLWUhNgn0+9tlte root@marie-desktop"];
  allSystems = artemis ++ delphi ++ wsl ++ marie-nas;
  users = marie-desktop-wsl ++ marie-desktop;
in
{
  "cloudflare-api-key.age".publicKeys = users ++ allSystems;
  "authentik-secrets.age".publicKeys = users ++ artemis;
  "miniflux-credentials.age".publicKeys = users ++ artemis;
  "grafana-oauth-client-secret.age".publicKeys = users ++ artemis;
  "synapse-sso-config.age".publicKeys = users ++ artemis;
  "artemis-wg-privatekey.age".publicKeys = users ++ artemis;
  "pgrok-client-secret.age".publicKeys = users ++ artemis;
  "paperless-env.age".publicKeys = users ++ artemis;
  "curseforge-api-key.age".publicKeys = users ++ delphi;
  "minio.age".publicKeys = users ++ delphi;
  "turn-secret.age".publicKeys = users ++ delphi;
  "turn-secret-synapse-config.age".publicKeys = users ++ artemis;

  "git-email.age".publicKeys = users;

  "../hosts/artemis/dn42/peers/emma/wg-private.age".publicKeys = users ++ artemis;
  "../hosts/artemis/dn42/peers/kioubit/wg-private.age".publicKeys = users ++ artemis;
  "../hosts/artemis/dn42/peers/maraun/wg-private.age".publicKeys = users ++ artemis;
  "../hosts/artemis/dn42/peers/adri/wg-private.age".publicKeys = users ++ artemis;

  "../hosts/artemis/secrets/renovate-token.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/renovate-github-token.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/pgbackrest.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/attic.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/restic.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/r2-monitoring-token.age".publicKeys = users ++ artemis;
  "../hosts/gitlabber/cachix-auth-token.age".publicKeys = users ++ gitlabber;
  "../hosts/gitlabber/forgejo-runner.age".publicKeys = users ++ gitlabber;
  "../hosts/artemis/applications/hedgedoc/env.age".publicKeys = users ++ artemis;

  "../hosts/marie-desktop/secrets/restic-password.age".publicKeys = marie-desktop ++ marie-desktop-host;
}
