{ pkgs, modulesPath, config, inputs, utils, ... }:

let
  nixConfig = pkgs.writeTextFile {
    name = "nix-config";
    text = ''
      build-users-group =
      experimental-features = nix-command flakes
      max-jobs = auto
      extra-substituters = https://uwumarie.cachix.org
      extra-trusted-public-keys = uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo=
    '';
    destination = "/etc/nix/nix.conf";
  };
  nixImage = pkgs.dockerTools.streamLayeredImage {
    name = "forgejo-runner-nix";
    tag = "latest";
    contents = with pkgs; [
      nixConfig

      gnutar
      zstd
      cacert
      bash
      nodejs
      gitMinimal
      coreutils
      busybox
      nix
      dockerTools.fakeNss
      dockerTools.caCertificates

      podman
      buildah
      skopeo
    ];
    config.Cmd = ["/bin/bash"];
  };
  name = "gitlabber-1";
  escapedName = utils.escapeSystemdPath name;
in

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];
  networking = {
    hostName = "gitlabber-forgejo-runner";
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Type = [ "ether" ];
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        KeepConfiguration = "yes";
      };
    };
  };
  services.resolved.enable = false;
  uwumarie.profiles = {
    nspawn = true;
  };

  users.users.marie.initialHashedPassword = "$y$j9T$QuvIaMM4RuzxPVXeK4lay.$yui1R8EHsBwdYNw48lML3iEkJMGNkMRAVgeVFDq6hD2";

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };

  systemd.services.forgejo-runner-nix-image = {
    wantedBy = ["multi-user.target"];
    after = ["podman.service"];
    requires = ["podman.service"];
    path = [
      config.virtualisation.podman.package
    ];

    script = ''
      ${nixImage} | podman load -q
    '';

    serviceConfig = {
      RuntimeDirectory = "forgejo-runner-nix-image";
      WorkingDirectory = "/run/forgejo-runner-nix-image";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services."gitea-runner-${escapedName}" = {
    after = [ "forgejo-runner-nix-image.service" ];
    requires = [ "forgejo-runner-nix-image.service" ];
    serviceConfig.Slice = "podman.slice";
  };

  age.secrets.forgejo-runner-1.file = ./secrets/forgejo-runner-1.age;
  services.gitea-actions-runner = {
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.forgejo-actions-runner;
    instances = {
      ${name} = {
        enable = true;
        inherit name;
        url = "https://git.marie.cologne";
        labels = [ "nix:docker://forgejo-runner-nix" ];
        tokenFile = config.age.secrets.forgejo-runner-1.path;
      };
    };
  };

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
