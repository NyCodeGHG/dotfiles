{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];
  networking.hostName = "gitlabber-forgejo-runner";
  uwumarie.profiles = {
    nspawn = true;
    openssh = false;
  };

  system.stateVersion = "23.11";
  users.users.marie.initialHashedPassword = "$y$j9T$QuvIaMM4RuzxPVXeK4lay.$yui1R8EHsBwdYNw48lML3iEkJMGNkMRAVgeVFDq6hD2";
}
