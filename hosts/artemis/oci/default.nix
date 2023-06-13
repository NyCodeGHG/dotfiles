{ config, pkgs, lib, ... }:
{
  systemd.services.oci-instance = {
    serviceConfig = {
      User = "oci-terraform";
      Type = "oneshot";
      WorkingDirectory = "/var/lib/oci-terraform";
      EnvironmentFile = [
        config.age.secrets.oci-terraform.path
        config.age.secrets.discord-webhook.path
      ];
    };
    environment."TF_VAR_private_key_path" = config.age.secrets.oci-private-key.path;
    script = ''
      set -eo pipefail
      if [ -f "/var/lib/oci-terraform/.success" ]; then
        exit 0
      fi

      ln -sf ${./main.tf} main.tf
      ln -sf ${./.terraform.lock.hcl} .terraform.lock.hcl
      ${pkgs.terraform}/bin/terraform init
      ${pkgs.terraform}/bin/terraform apply -auto-approve
      
      touch .success
      ${pkgs.discord-sh}/bin/discord.sh \
        --username "oci-terraform" \
        --text "<@449893028266770432>" \
        --title "Successfully created Oracle Free Compute instance." \
    '';
  };
  systemd.timers.oci-instance = {
    wantedBy = [ "timers.target" ];
    partOf = [ "oci-instance.service" ];
    timerConfig = {
      OnCalendar = "*:0/5";
    };
  };
  users.users.oci-terraform = {
    isSystemUser = true;
    home = "/var/lib/oci-terraform";
    createHome = true;
    group = "oci-terraform";
  };
  users.groups.oci-terraform = { };
  age.secrets.oci-terraform.file = ../../../secrets/oci-terraform.age;
  age.secrets.discord-webhook.file = ../../../secrets/discord-webhook.age;
  age.secrets.oci-private-key = {
    file = ../../../secrets/oci-private-key.age;
    owner = "oci-terraform";
  };
}
