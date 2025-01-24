{ lib, config, inputs, ... }:
{
  virtualisation.oci-containers.containers.minecraft = {
    image = "docker.io/itzg/minecraft-server:java21";
    environment = {
      EULA = "true";
      INIT_MEMORY = "4G";
      MAX_MEMORY = "10G";
      ENABLE_ROLLING_LOGS = "true";
      TZ = "Europe/Berlin";
      ENABLE_WHITELIST = "true";
      WHITELIST = "uwumarie,techtoto,emmabtw";
      OPS = "uwumarie";
      USE_NATIVE_TRANSPORT = "true";
      VIEW_DISTANCE = "16";
      SPAWN_PROTECTION = "0";
      ALLOW_FLIGHT = "true";
      TYPE = "MODRINTH";
      USE_AIKAR_FLAGS = "true";
      UID = toString config.users.users.minecraft.uid;
      GID = toString config.users.groups.minecraft.gid;
      MODRINTH_MODPACK = "adrenaline";
      VERSION = "1.21.4";
      MODRINTH_PROJECTS = lib.concatStringsSep "," [
        "datapack:terralith"
        "datapack:halbcraft"
        "datapack:halbcore"
      ];
      RESOURCE_PACK = "https://cdn.modrinth.com/data/K7Ih6CPH/versions/uIcp8Xa5/halbcraft_RP_04.zip";
      RESOURCE_PACK_SHA1 = "559984e4b807594b0f8f87c153fd897d4fd6f2e5";
      MODRINTH_DEFAULT_VERSION_TYPE = "beta";
    };
    environmentFiles = [ config.age.secrets.curseforge-api-key.path ];
    volumes = [
      "/var/lib/minecraft/halbcraft:/data"
    ];
    ports = [
      "25565:25565"
      "24454:24454/udp"
    ];
    user = "${toString config.users.users.minecraft.uid}:${toString config.users.groups.minecraft.gid}";
  };
  systemd.tmpfiles.settings."10-minecraft"."/var/lib/minecraft/halbcraft".d = {
    group = "minecraft";
    mode = "0775";
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
