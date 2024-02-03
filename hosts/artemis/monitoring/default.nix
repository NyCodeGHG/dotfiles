{ ... }:
{
  imports = [
    ./grafana.nix
    ./prometheus
    ./uptime-kuma.nix
  ];
}
