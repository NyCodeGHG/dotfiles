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
      VIEW_DISTANCE = "20";
      USE_SIMD_FLAGS = "true";
      TYPE = "AUTO_CURSEFORGE";
      CF_BASE_DIR = "/data";
      CF_PAGE_URL = "https://www.curseforge.com/minecraft/modpacks/cabin/files/5054719";
      CF_EXCLUDE_MODS = "legendary-tooltips";
      # CF_SERVER_MOD = "/modpacks/MechanicalMastery-Server-r1.5.0.zip";
      # SERVER_IP = "::";
      # JVM_OPTS = "-Djava.net.preferIPv6Addresses=true";
      USE_AIKAR_FLAGS = "true";
      UID = toString config.users.users.minecraft.uid;
      GID = toString config.users.groups.minecraft.gid;
    };
    environmentFiles = [ config.age.secrets.curseforge-api-key.path ];
    volumes = [
      "/var/lib/minecraft/cabin:/data"
    ];
    extraOptions = [
      "--network=host"
    ];
    user = "${toString config.users.users.minecraft.uid}:${toString config.users.groups.minecraft.gid}";
  };
  networking.firewall.allowedTCPPorts = [ 25565 ];
  systemd.tmpfiles.settings."10-minecraft"."/var/lib/minecraft/cabin".d = {
    group = "minecraft";
    mode = "0700";
    user = "minecraft";
  };
  users = {
    users.minecraft = {
      isSystemUser = true;
      group = "minecraft";
      home = "/var/lib/minecraft";
      uid = 984;
    };
    groups.minecraft = {
      gid = 982;
    };
  };
  age.secrets.curseforge-api-key.file = "${inputs.self}/secrets/curseforge-api-key.age";
  virtualisation.podman.defaultNetwork.settings.ipv6_enabled = true;
}
