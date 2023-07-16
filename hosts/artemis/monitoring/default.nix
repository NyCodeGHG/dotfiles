{ ... }:
{
  imports = [
    ./loki
    ./grafana.nix
    ./prometheus
    ./uptime-kuma.nix
    ./tempo.nix
  ];
}
