{ config, pkgs, lib, ... }:
{
  imports = [
    ./loki
    ./grafana.nix
    ./prometheus.nix
    ./uptime-kuma.nix
  ];
}
