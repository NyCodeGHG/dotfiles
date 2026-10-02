{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.mitmproxy
  ];
}
