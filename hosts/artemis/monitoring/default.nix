{ config, pkgs, lib, ... }:
{
  imports = [
    ./loki
    ./grafana.nix
    ./uptime-kuma.nix
  ];
}
