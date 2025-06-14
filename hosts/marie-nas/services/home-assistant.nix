{ pkgs, config, ... }:
{
  services.home-assistant = {
    enable = true;
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
      "ping"
      "jellyfin"
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
      sleep_as_android
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
    '';
  };
}
