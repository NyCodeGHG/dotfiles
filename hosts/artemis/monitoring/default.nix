{ ... }:
{
  imports = [
    ./grafana.nix
    ./prometheus
    ./victorialogs.nix
    ./victoriametrics.nix
  ];
}
