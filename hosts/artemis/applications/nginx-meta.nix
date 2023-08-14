{ lib, ... }:
let
  sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp";
in
{
  services.nginx.virtualHosts."marie.cologne" = {
    locations."= /ssh.txt" = lib.mkForce {
      return = "200 '${sshKeys}'";
      extraConfig = ''
        add_header Content-Type text/plain;
      '';
    };
  };
}