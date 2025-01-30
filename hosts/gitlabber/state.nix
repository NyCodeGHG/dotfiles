{ ... }:
{
  users.mutableUsers = false;
  preservation = {
    enable = true;
    preserveAt."/state" = {
      directories = [
        { directory = "/root"; }
        "/var/db/sudo"
        { directory =  "/var/lib/nixos"; inInitrd = true; }
        "/var/lib/systemd"
        "/var/lib/tailscale"
        "/var/log"
        "/var/lib/acme"
      ];
      files = [
        { file = "/etc/machine-id"; inInitrd = true; how = "symlink"; configureParent = true; }
        { file = "/etc/NIXOS"; inInitrd = true; how = "symlink"; }
        { file = "/etc/ssh/ssh_host_ed25519_key"; mode = "0700"; inInitrd = true; }
        { file = "/etc/ssh/ssh_host_ed25519_key.pub"; inInitrd = true; }
        { file = "/etc/ssh/ssh_host_rsa_key"; mode = "0700"; inInitrd = true; }
        { file = "/etc/ssh/ssh_host_rsa_key.pub"; inInitrd = true; }
      ];
    };
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [ "" "/state/etc/machine-id" ];
    serviceConfig.ExecStart = [ "" "systemd-machine-id-setup --commit --root /state" ];
  };
}
