{ ... }:
{
  imports = [
    ./loki
    ./grafana.nix
    ./prometheus.nix
    ./uptime-kuma.nix
    ./tempo.nix
  ];
}
