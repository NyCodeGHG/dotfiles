{ pkgs, config, lib, ... }:
{
  virtualisation.oci-containers.containers.minecraft = {
    image = "docker.io/itzg/minecraft-server:java17";
    environment = {
      EULA = "true";
      VERSION = "1.20.1";
      INIT_MEMORY = "2G";
      MAX_MEMORY = "8G";
      USE_AIKAR_FLAGS = "true";
      TYPE = "PAPER";
      ENABLE_ROLLING_LOGS = "true";
      TZ = "Europe/Berlin";
      ENABLE_WHITELIST = "true";
      OPS = "ec6a3dab-6b35-4596-9d7f-f9bdd773874f";
      USE_NATIVE_TRANSPORT = "true";
      SIMULATION_DISTANCE = "12";
      VIEW_DISTANCE = "24";
      USE_SIMD_FLAGS = "true";
    };
    ports = [
      "25565:25565"
    ];
    volumes = [
      "/var/lib/minecraft:/data"
    ];
    extraOptions = [
      # "--health-cmd=mc-health"
      # "--health-interval=5s"
      # "--health-retries=20"
    ];
  };
  systemd.services.podman-minecraft.preStart = ''
    mkdir -p /var/lib/minecraft
  '';
}
