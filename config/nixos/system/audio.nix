{ lib, config, ... }:
{
  options.uwumarie.profiles.audio = lib.mkEnableOption "audio profile";
  config = lib.mkIf config.uwumarie.profiles.audio {
    services.pipewire = {
      enable = true;
      jack.enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    hardware.pulseaudio.enable = false;
  };
}
