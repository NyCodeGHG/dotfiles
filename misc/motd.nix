{
  pkgs,
  config,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [figlet];
  programs.rust-motd = {
    enable = true;
    refreshInterval = "*:0/5"; # Every 5 minutes starting from minute 0.
    settings = builtins.fromTOML ''
      [global]
      progress_full_character = "="
      progress_empty_character = "="
      progress_prefix = "["
      progress_suffix = "]"
      time_format = "%Y-%m-%d %H:%M:%S"

      [banner]
      color = "magenta"
      command = "hostname | figlet -f slant"

      [weather]
      url = "https://wttr.in/"
      user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"

      # [service_status]
      # Accounts = "accounts-daemon"
      # Cron = "cron"

      # [docker]
      # Local containers MUST start with a slash
      # https://github.com/moby/moby/issues/6705
      # "/nextcloud-nextcloud-1" = "Nextcloud"
      # "/nextcloud-nextcloud-mariadb-1" = "Nextcloud Database"

      [uptime]
      prefix = "Up"

      # [user_service_status]
      # gpg-agent = "gpg-agent"

      # [ssl_certificates]
      # sort_method = "manual"
      #
      #    [ssl_certificates.certs]
      #    CertName1 = "/path/to/cert1.pem"
      #    CertName2 = "/path/to/cert2.pem"

      [filesystems]
      root = "/"

      [memory]
      swap_pos = "beside" # or "below" or "none"

      # [fail_2_ban]
      # jails = ["sshd", "anotherjail"]

      # [last_login]
      # sally = 2
      # jimmy = 1

      # [last_run]
    '';
  };
}
