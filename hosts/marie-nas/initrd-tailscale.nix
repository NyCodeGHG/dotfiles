{
  pkgs,
  config,
  utils,
  ...
}:
let
  tailscaled = "${pkgs.tailscale}/bin/.tailscaled-wrapped";
in
{
  boot.initrd.supportedFilesystems.vfat = true;

  boot.initrd.systemd = {
    storePaths = [ tailscaled ];
    contents."/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    mounts =
      let
        boot = config.fileSystems."/boot";
      in
      [
        {
          what = boot.device;
          type = boot.fsType;
          options = "umask=0077,flush";
          where = "/boot";
          unitConfig.DefaultDependencies = false;
          wants = [ "systemd-fsck@${utils.escapeSystemdPath boot.device}.service" ];
          after = [ "systemd-fsck@${utils.escapeSystemdPath boot.device}.service" ];
          before = [
            "shutdown.target"
            "initrd-switch-root.target"
          ];
          conflicts = [
            "shutdown.target"
            "initrd-switch-root.target"
          ];
        }
      ];

    services.tailscaled = {
      description = "Tailscale node agent";
      wantedBy = [ "emergency.target" ];
      wants = [ "tpm2.target" ];
      after = [
        "network.target"
        "tpm2.target"
      ];
      before = [
        "shutdown.target"
        "initrd-switch-root.target"
      ];
      conflicts = [
        "shutdown.target"
        "initrd-switch-root.target"
      ];
      unitConfig = {
        DefaultDependencies = false;
        RequiresMountsFor = "/boot/tailscale";
      };
      serviceConfig = {
        ExecStart = "@${tailscaled} tailscaled --tun=userspace-networking --encrypt-state --statedir=/var/lib/tailscale --state=/boot/tailscale/tailscaled.state";
        RuntimeDirectory = "tailscale";
        StateDirectory = "tailscale";
        Restart = "on-failure";
      };
    };

    paths.tailscaled-ask-password = {
      description = "Start Tailscale on pending password requests";
      wantedBy = [ "initrd.target" ];
      before = [
        "shutdown.target"
        "initrd-switch-root.target"
      ];
      conflicts = [
        "shutdown.target"
        "initrd-switch-root.target"
      ];
      unitConfig.DefaultDependencies = false;
      pathConfig = {
        DirectoryNotEmpty = "/run/systemd/ask-password";
        Unit = "tailscaled.service";
      };
    };
  };
}
