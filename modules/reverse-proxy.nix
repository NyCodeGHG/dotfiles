{ config, pkgs, lib, inputs, ... }:
with lib;
let
  virtualHost = import "${inputs.nixpkgs}/nixos/modules/services/web-servers/nginx/vhost-options.nix" {
    inherit config lib;
  };
  cfg = config.uwumarie.reverse-proxy;
  mkMergeTopLevel = names: attrs: getAttrs names (
    mapAttrs (k: v: mkMerge v) (foldAttrs (n: a: [ n ] ++ a) [ ] attrs)
  );
in
{
  options.uwumarie.reverse-proxy = {
    enable = mkEnableOption "reverse-proxy";
    commonOptions = mkOption {
      type = types.submodule virtualHost;
      default = { };
    };
    services = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
    };
  };

  config.services.nginx.virtualHosts = mapAttrs (name: vhostConfig: cfg.commonOptions // vhostConfig) cfg.services;
}
