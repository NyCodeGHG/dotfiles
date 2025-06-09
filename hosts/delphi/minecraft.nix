{ lib, config, inputs, ... }:
{
  virtualisation.oci-containers.containers.minecraft = {
    image = "docker.io/itzg/minecraft-server:java24";
    environment = {
      EULA = "true";
      INIT_MEMORY = "5G";
      MAX_MEMORY = "5G";
      ENABLE_ROLLING_LOGS = "true";
      TZ = "Europe/Berlin";
      ENABLE_WHITELIST = "true";
      WHITELIST = "uwumarie,techtoto";
      OPS = "uwumarie,techtoto";
      USE_NATIVE_TRANSPORT = "true";
      VIEW_DISTANCE = "20";
      SPAWN_PROTECTION = "0";
      ALLOW_FLIGHT = "true";
      TYPE = "MODRINTH";
      USE_AIKAR_FLAGS = "true";
      UID = toString config.users.users.minecraft.uid;
      GID = toString config.users.groups.minecraft.gid;
      MODRINTH_MODPACK = "adrenaline";
      VERSION = "1.21.5";
      MODRINTH_PROJECTS = lib.concatStringsSep "," [
        "distanthorizons"
        "shared-advancements"
        "fastback"
        "spark"
      ];
      MODRINTH_ALLOWED_VERSION_TYPE = "alpha";
      MODRINTH_DEFAULT_VERSION_TYPE = "alpha";
      MODRINTH_DOWNLOAD_DEPENDENCIES = "required";
    };
    environmentFiles = [ config.age.secrets.curseforge-api-key.path ];
    user = "${toString config.users.users.minecraft.uid}:${toString config.users.groups.minecraft.gid}";
    volumes = [
      "/var/lib/minecraft/all-advancements:/data"
    ];
    ports = [ "25565:25565" ];
  };
  systemd.tmpfiles.settings."10-minecraft"."/var/lib/minecraft/all-advancements".d = {
    group = "minecraft";
    mode = "0770";
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
  networking.firewall = {
    # open minecraft port
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 24454 ];
  };
  age.secrets.curseforge-api-key.file = "${inputs.self}/secrets/curseforge-api-key.age";
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };
  users.users.marie.extraGroups = [ "minecraft" ];
}
