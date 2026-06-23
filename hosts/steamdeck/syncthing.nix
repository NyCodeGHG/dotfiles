{ pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    dataDir = "/home/marie";
    user = "marie";
    group = "users";
    openDefaultPorts = true;
    settings = {
      devices = {
        marie-desktop.id = "6TPYJWH-7QOBNQI-RCUCWBM-SYKPS6M-XOS3YXB-4LFTLBE-BCPOJ6L-ET6PJAG";
      };
      folders = {
        satisfactory-saves = {
          id = "juy6j-mmhjp";
          devices = [ "marie-desktop" ];
          label = "Satisfactory Saves";
          path = "/home/marie/Games/Heroic/Prefixes/Satisfactory/pfx/drive_c/users/steamuser/AppData/Local/FactoryGame/Saved/SaveGames/";
        };
        prismlauncher = {
          id = "prismlauncher";
          devices = [ "marie-desktop" ];
          label = "PrismLauncher";
          path = "/home/marie/.local/share/PrismLauncher/";
          ignorePatterns = [
            "/accounts.json"
            "/metacache"
            "/images"
            "/assets"
            "/libraries"
            "/meta"
            "/cache"
            "/logs"
            "/translations"
          ];
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.syncthingtray ];
}
