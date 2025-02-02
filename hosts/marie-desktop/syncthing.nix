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
  };
}
