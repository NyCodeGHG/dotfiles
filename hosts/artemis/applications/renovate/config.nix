{
  autodiscover = true;
  autodiscoverTopics = ["managed-by-renovate"];
  nix.enabled = true;
  lockFileMaintenance.enabled = true;
  baseDir = "/var/lib/renovate/";
  cacheDir = "/var/lib/renovate/cache";
  username = "renovate-bot";
  gitAuthor = "Renovate <renovate@git.marie.cologne>";
  platform = "gitea";
  endpoint = "https://git.marie.cologne";
  # experimental
  osvVulnerabilityAlerts = true;
}