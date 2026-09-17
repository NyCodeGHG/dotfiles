let
  marie-desktop = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdNaJgKxA021pqrbkoMiP2a9buYZUXfG5q01y2h8YOa"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA56+5iSfyhYaTU3jc4Hl6G2qqHOUG9SMymPr5dfwbZf"
  ];
  artemis = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis"
  ];
  delphi = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3 root@delphi"
  ];
  wsl = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpKCSJGPFfckgr1/X1Rv7jeOe9E8tYmP1iqogzSXF+u" ];
  gitlabber = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM891QqZPoML7r5MdzprykGqeK0eP33D24iaR4QaZdRN" ];
  marie-nas = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwvQy3cK9gGwFEf5UGCxQ61j8Kv30JDAZ39FOtKkrCQ" ];
  allSystems = artemis ++ delphi ++ wsl ++ marie-nas;
  users = marie-desktop;
in
{
  "cloudflare-api-key.age".publicKeys = users ++ allSystems;
  "miniflux-credentials.age".publicKeys = users ++ artemis;
  "grafana-oauth-client-secret.age".publicKeys = users ++ artemis;
  "synapse-sso-config.age".publicKeys = users ++ artemis;
  "artemis-wg-privatekey.age".publicKeys = users ++ artemis;

  "git-email.age".publicKeys = marie-desktop;
  "grafana-mcp-token.age".publicKeys = marie-desktop;

  "../hosts/artemis/dn42/peers/kioubit/wg-private.age".publicKeys = users ++ artemis;

  "../hosts/artemis/secrets/renovate-token.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/renovate-github-token.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/attic.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/restic.age".publicKeys = users ++ artemis;
  "../hosts/artemis/secrets/garage-rpc-secret.age".publicKeys = users ++ artemis;
  "../hosts/gitlabber/forgejo-runner-token.age".publicKeys = users ++ gitlabber;
}
