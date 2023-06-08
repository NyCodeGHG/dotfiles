{ config, lib, pkgs, inputs, ... }:
with lib;
let
  virtualHost = import "${inputs.nixpkgs}/nixos/modules/services/web-servers/nginx/vhost-options.nix" {
    inherit config lib;
  };
  cfg = config.uwumarie.reverse-proxy;
in
{
  options.uwumarie.reverse-proxy = {
    enable = mkEnableOption "reverse-proxy";
    commonOptions = mkOption {
      type = types.submodule virtualHost;
      default = { };
    };
    services = mkOption {
      type = types.attrsOf (types.submodule virtualHost);
      default = { };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts = builtins.mapAttrs (name: value: cfg.commonOptions // value) cfg.services;
    };
  };
}
