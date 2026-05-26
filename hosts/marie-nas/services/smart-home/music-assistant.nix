{ lib, ... }:
{
  services.music-assistant = {
    enable = true;
    openFirewall = true;
    providers = [
      "airplay"
      "airplay_receiver"
      "ard_audiothek"
      "chromecast"
      "dlna"
      "filesystem_local"
      "filesystem_nfs"
      "filesystem_smb"
      "genius_lyrics"
      "hass"
      "hass_players"
      "jellyfin"
      "spotify"
      "soundcloud"
      "spotify_connect"
      "sendspin"
    ];
  };

  services.nginx.virtualHosts."mass.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:8095";
    proxyWebsockets = true;
  };

  systemd.services.music-assistant.serviceConfig.MemoryDenyWriteExecute = lib.mkForce false;
}
