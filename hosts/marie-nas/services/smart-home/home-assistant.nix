{
  pkgs,
  lib,
  ...
}:
{
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
      "otbr"
      "homeassistant_connect_zbt2"
      "mcp_server"
      "openweathermap"
      "co2signal"
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
      waste_collection_schedule
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
}
