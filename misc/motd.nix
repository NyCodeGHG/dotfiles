{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.rust-motd = {
    enable = true;
    refreshInterval = "*:0/5"; # Every 5 minutes starting from minute 0.
    settings = {
      global = {
        progress_full_character = "=";
        progress_empty_character = "=";
        progress_prefix = "[";
        progress_suffix = "]";
        time_format = "%Y-%m-%d %H:%M:%S";
      };
      banner = {
        color = "magenta";
        command = "hostname | figlet -f slant";
      };
      weather = {
        url = "https://wttr.in/?format=4";
      };
      uptime = {
        prefix = "Uptime";
      };
      filesystems = {
        root = "/";
      };
      memory = {
        swap_pos = "beside";
      };
    };
  };
  systemd.services.rust-motd = {
    path = with pkgs; [figlet hostname openssl];
    serviceConfig = {
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
    };
  };
}
