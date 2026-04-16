{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  containers.home-assistant = {
    privateNetwork = true;
    privateUsers = "pick";
    autoStart = true;
    hostBridge = "br0";

    specialArgs = { inherit inputs; };

    config =
      { lib, ... }:
      {
        imports = [
          inputs.self.nixosModules.config
          ./networking.nix
        ];
        uwumarie.profiles = {
          users.marie = false;
          openssh = false;
          headless = true;
        };
        nix.gc.automatic = false;
        security.pam.services.login.updateWtmp = lib.mkForce false;
        users.allowNoPasswordLogin = true;

        networking = {
          useHostResolvConf = false;
          useDHCP = false;
        };

        nixpkgs.pkgs = pkgs;

        system.stateVersion = "26.05";
      };
    bindMounts = {
      "/etc/nix" = {
        hostPath = "/etc/nix";
        isReadOnly = true;
      };
    };
  };
  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        ../../../../patches/hass-ipv6-prefix.patch
      ];
    });
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "hue"
      "nanoleaf"
      "cast"
      "ipp"
      "homekit_controller"
      "homekit"
      "control4"
      "ping"
      "jellyfin"
      "fritz"
      "google_drive"
      "esphome"
      "matter"
      "androidtv_remote"
      "androidtv"
      "vesync"
      "workday"
      "holiday"
      "google"
      "enocean"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        radius = 15;
        unit_system = "metric";
        currency = "EUR";
        country = "DE";
        time_zone = "Europe/Berlin";
        external_url = "https://hass.marie.cologne";
        internal_url = "https://hass.marie.cologne";
      };
      adaptive_lighting = {
        lights = [
          "light.marie_deckenlampe"
          "light.shapes_5e66"
        ];
        detect_non_ha_changes = true;
      };
      mqtt = { };
    };
    customComponents = with pkgs.home-assistant-custom-components; [
      adaptive_lighting
      dwd
    ];
    customLovelaceModules = [
      pkgs.lovelace-horizon-card
      pkgs.home-assistant-custom-lovelace-modules.mushroom
    ];
  };

  services.nginx.virtualHosts."hass.marie.cologne".locations."/" = {
    proxyPass = "http://[::1]:8123";
    proxyWebsockets = true;
    extraConfig = ''
      proxy_buffering off;
      client_max_body_size 100M;
    '';
  };

  services.matter-server.enable = true;

  systemd.services.matter-server.serviceConfig.BindReadOnlyPaths = lib.mkForce [
    "/nix/store"
    "/run/dbus"
    "/etc/resolv.conf"
  ];
}
