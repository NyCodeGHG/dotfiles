{ modulesPath, pkgs, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];
  environment = {
    systemPackages = [ pkgs.neovim-unwrapped ];
    shellAliases = {
      "vim" = "nvim";
    };
  };
  services.openssh = {
    enable = true;
    openFirewall = true;
  };
  users.users.nixos.password = "meow";
}
