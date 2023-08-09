{ config, inputs, ... }:
{
  virtualisation.oci-containers.containers.minecraft = {
    image = "docker.io/itzg/minecraft-server:java17";
    environment = {
      EULA = "true";
      INIT_MEMORY = "4G";
      MAX_MEMORY = "10G";
      ENABLE_ROLLING_LOGS = "true";
      TZ = "Europe/Berlin";
      ENABLE_WHITELIST = "true";
      OPS = "ec6a3dab-6b35-4596-9d7f-f9bdd773874f";
      USE_NATIVE_TRANSPORT = "true";
      SIMULATION_DISTANCE = "16";
      VIEW_DISTANCE = "16";
      USE_SIMD_FLAGS = "true";
      TYPE = "AUTO_CURSEFORGE";
      CF_BASE_DIR = "/data";
      CF_PAGE_URL = "https://www.curseforge.com/minecraft/modpacks/mechanical-mastery/files/4684133";
      # CF_SERVER_MOD = "/modpacks/MechanicalMastery-Server-r1.5.0.zip";
    };
    environmentFiles = [ config.age.secrets.curseforge-api-key.path ];
    ports = [
      "25565:25565"
      "9101:9100"
    ];
    volumes = [
      "/var/lib/minecraft/mechanical-mastery:/data"
      "/var/lib/minecraft/modpacks:/modpacks"
    ];
    extraOptions = [
      "--no-healthcheck"
    ];
  };
  systemd.services.podman-minecraft = {
    preStart = ''
      mkdir -p /var/lib/minecraft/mechanical-mastery /var/lib/minecraft/modpacks
    '';
  };
  age.secrets.curseforge-api-key.file = "${inputs.self}/secrets/curseforge-api-key.age";
}
