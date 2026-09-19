{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
    "${modulesPath}/virtualisation/lxc-image-metadata.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];
  disabledModules = [ "virtualisation/lxc-instance-common.nix" ];

  security.sudo-rs.wheelNeedsPassword = false;
  networking = {
    useHostResolvConf = false;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks."99-lxc-veth-default-dhcp" = {
      matchConfig = {
        Type = "ether";
        Kind = "veth";
        Name = [
          "en*"
          "eth*"
        ];
      };
      DHCP = "yes";
      networkConfig.IPv6PrivacyExtensions = "kernel";
    };
  };
}
