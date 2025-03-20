{ pkgs, lib, ... }:
{
  services.redis.package = lib.mkDefault pkgs.valkey;
}
