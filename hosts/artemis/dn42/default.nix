{ pkgs, config, libs, ... }:
{
  imports = [
    ./peers/emma.nix
  ];
  systemd.network = {
    enable = true;
    networks = {
      # "60-dn42" = {
      #   name = "lo";
      #   address = [
      #     "fdf1:3ba4:9723::1/128"
      #   ];
      # };
    };
  };
}
