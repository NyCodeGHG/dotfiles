{ config, inputs, ... }:
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
      TYPE = "AUTO_CURSEFORGE";
      CF_SLUG = "fear-nightfall";
      CF_FILENAME_MATCHER = "Fear Nightfall Remains of Chaos-v1.0.6.zip";
      CF_EXCLUDE_MODS = "yungs-menu-tweaks";
      USE_AIKAR_FLAGS = "true";
      UID = toString config.users.users.minecraft.uid;
      GID = toString config.users.groups.minecraft.gid;
    };
    environmentFiles = [ config.age.secrets.curseforge-api-key.path ];
    volumes = [
      "/var/lib/minecraft/fear-nightfall:/data"
    ];
    ports = [
      "25565:25565"
      "24454:24454/udp"
    ];
    user = "${toString config.users.users.minecraft.uid}:${toString config.users.groups.minecraft.gid}";
  };
  systemd.tmpfiles.settings."10-minecraft"."/var/lib/minecraft/fear-nightfall".d = {
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
