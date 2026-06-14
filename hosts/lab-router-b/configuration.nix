{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    ../../config/nixos/lab-router-common.nix
  ];

  networking = {
    useDHCP = false;
    hostName = "lab-router-b";
  };

  # Make prompt magenta
  environment.interactiveShellInit = ''
    PS1='\[\033[1;35m\][\u@\h:\w]\$\[\033[0m\] '
  '';

  services.bird = {
    enable = true;
    config = builtins.readFile ./bird.conf;
  };
}
