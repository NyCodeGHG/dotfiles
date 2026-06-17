{ ... }:
{
  imports = [
    ./grafana.nix
    ./victorialogs.nix
    ./victoriametrics.nix
  ];

  environment.etc."alloy/blackbox.alloy".source = ./blackbox.alloy;
}
