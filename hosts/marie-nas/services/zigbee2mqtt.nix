{ config, pkgs, ... }:
{
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.zigbee2mqtt_2;
    settings = {
      version = 4;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://127.0.0.1:1883";
        user = "zigbee2mqtt";
        password = "!${config.age.secrets.zigbee2mqtt.path} password";
      };
      serial = {
        port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_b2755e278739ef11a42a53f454516304-if00-port0";
        adapter = "ember";
        rtscts = false;
      };
      advanced = {
        channel = 11;
        network_key = "!${config.age.secrets.zigbee2mqtt.path} network_key";
        pan_id = 34317;
        ext_pan_id = [165 153 115 249 223 26 107 129];
      };
      homeassistant.enabled = true;
      availability.enabled = true;
      frontend = {
        enabled = true;
        port = 8081;
        url = "https://zigbee2mqtt.home.marie.cologne";
      };
    };
  };

  systemd.services.zigbee2mqtt = {
    after = [ "mosquitto.service" ];
    wants = [ "mosquitto.service" ];
  };

  age.secrets.zigbee2mqtt = {
    file = ../secrets/zigbee2mqtt.age;
    owner = "zigbee2mqtt";
    group = "zigbee2mqtt";
    name = "zigbee2mqtt.yaml";
  };

  services.nginx.virtualHosts."zigbee2mqtt.home.marie.cologne" = {
    useACMEHost = "zigbee2mqtt.home.marie.cologne";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8081";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."zigbee2mqtt.home.marie.cologne" = { };
}
