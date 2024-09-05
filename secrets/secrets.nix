let
  marie-desktop-wsl = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"];
  artemis = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis"];
  delphi = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3 root@delphi"];
  wsl = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpKCSJGPFfckgr1/X1Rv7jeOe9E8tYmP1iqogzSXF+u"];
  gitlabber = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0hOumgZQqYpGnraf+hjPXSEcTVH8QKa25WLW7r1Psk"];
  allSystems = artemis ++ delphi ++ wsl;
  users = marie-desktop-wsl;
in
{
  "cloudflare-api-key.age".publicKeys = users ++ allSystems;
  "authentik-secrets.age".publicKeys = users ++ artemis;
  "miniflux-credentials.age".publicKeys = users ++ artemis;
  "grafana-oauth-client-secret.age".publicKeys = users ++ artemis;
  "restic-repo.age".publicKeys = users ++ artemis;
  "b2-restic.age".publicKeys = users ++ artemis;
  "discord-webhook.age".publicKeys = users ++ artemis;
  "synapse-sso-config.age".publicKeys = users ++ artemis;
  "delphi-wg-privatekey.age".publicKeys = users ++ delphi;
  "artemis-wg-privatekey.age".publicKeys = users ++ artemis;
  "pgrok-client-secret.age".publicKeys = users ++ artemis;
  "paperless-env.age".publicKeys = users ++ artemis;
  "curseforge-api-key.age".publicKeys = users ++ delphi;
  "minio.age".publicKeys = users ++ delphi;
  "turn-secret.age".publicKeys = users ++ delphi;
  "turn-secret-synapse-config.age".publicKeys = users ++ artemis;

  "git-email.age".publicKeys = users ++ wsl;

  "../hosts/artemis/dn42/peers/emma/wg-private.age".publicKeys = users ++ artemis;
  "../hosts/artemis/dn42/peers/kioubit/wg-private.age".publicKeys = users ++ artemis;
  "../hosts/artemis/dn42/peers/maraun/wg-private.age".publicKeys = users ++ artemis;

  "../hosts/artemis/secrets/wg1-private.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/renovate-token.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/renovate-github-token.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/storage-box.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/pgbackrest.age".publicKeys = users ++ artemis;
  "../hosts/gitlabber/cachix-auth-token.age".publicKeys = users ++ gitlabber;
  "../hosts/gitlabber/forgejo-runner.age".publicKeys = users ++ gitlabber;
  "../hosts/artemis/applications/hedgedoc/env.age".publicKeys = users ++ artemis;
}
