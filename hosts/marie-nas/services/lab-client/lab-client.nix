{
  pkgs,
  inputs,
  ...
}:
{
  containers.lab-client = {
    privateNetwork = true;
    privateUsers = "pick";
    autoStart = true;
    hostBridge = "br0";
    extraVeths.lab-lan = {
      hostBridge = "br1";
    };

    specialArgs = { inherit inputs; };

    config =
      { lib, ... }:
      {
        imports = [
          inputs.self.nixosModules.config
          ./networking.nix
        ];
        uwumarie.profiles = {
          headless = true;
        };
        nix.gc.automatic = false;
        security.pam.services.login.updateWtmp = lib.mkForce false;

        networking = {
          useHostResolvConf = false;
          useDHCP = false;
        };

        nixpkgs.pkgs = pkgs;

        system.stateVersion = "26.05";

        environment.systemPackages = with pkgs; [
          firefox
          waypipe
        ];

        security.sudo-rs.wheelNeedsPassword = false;

        hardware.graphics.enable = true;
      };
    bindMounts = {
      "/etc/nix" = {
        hostPath = "/etc/nix";
        isReadOnly = true;
      };
    };
  };
}
