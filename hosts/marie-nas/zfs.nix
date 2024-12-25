{ ... }:
{
  networking.hostId = "5b001dfe";
  boot = {
    supportedFilesystems.zfs = true;
    zfs.forceImportRoot = false;
  };
}
