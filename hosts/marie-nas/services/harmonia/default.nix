{ config, ... }:
{
  uwumarie.harmonia-tailscale = {
    enable = true;
    signKeyPaths = [ config.age.secrets.harmonia-signing-key.path ];
  };
  age.secrets.harmonia-signing-key.file = ./signing-key.age;
}
