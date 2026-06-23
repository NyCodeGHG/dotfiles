{ ... }:
{
  services.syncthing = {
    enable = true;
    dataDir = "/home/marie";
    user = "marie";
    group = "users";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      devices = {
        steamdeck.id = "ELXO6JB-KGVO56W-EKNX3I5-Z6YHMOV-4AK26X6-7EJ66EG-BKOMBMU-U3CK2QB";
      };
      folders = {
        prismlauncher = {
          id = "prismlauncher";
          devices = [ "steamdeck" ];
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
}
