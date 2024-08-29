{ config, ... }:
{
  boot.supportedFilesystems.cifs = true;
  fileSystems."/mnt/storage-box" = {
    device = "//u421385.your-storagebox.de/u421385-sub1";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.storage-box.path}"
      "x-systemd.automount"
      "nofail" # don't fail on errors
      "_netdev" # require network for mount
      "vers=3"
      "iocharset=utf8"
      "nodev"
      "noexec"
      "nosuid"
    ];
  };
  age.secrets.storage-box.file = ./secrets/storage-box.age;
}
