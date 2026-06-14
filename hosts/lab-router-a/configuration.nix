{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    ../../config/nixos/lab-router-common.nix
  ];

  networking = {
    useDHCP = false;
    hostName = "lab-router-a";
  };

  # Make prompt blue
  environment.interactiveShellInit = ''
    PS1='\[\033[1;34m\][\u@\h:\w]\$\[\033[0m\] '
  '';

  services.bird = {
    enable = true;
    config = builtins.readFile ./bird.conf;
  };
}
