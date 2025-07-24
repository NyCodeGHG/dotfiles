{ pkgs, ... }:
{
  systemd.tmpfiles.settings.samba-shares = {
    "/srv/shares/marie".d = {
      group = "users";
      user = "marie";
      mode = "0700";
    };
    "/srv/shares/lena".d = {
      group = "users";
      user = "lena";
      mode = "0700";
    };
    "/srv/shares/media".d = {
      group = "media";
      user = "root";
      mode = "2770";
    };
    "/srv/shares/public".d = {
      group = "root";
      user = "root";
      mode = "2777";
    };
    "/srv/restic/marie".d = {
      group = "users";
      user = "marie";
      mode = "0700";
    };
  };
  users = {
    groups.media = { };
    users.marie.extraGroups = [ "media" ];
    users.guest = {
      isNormalUser = true;
      home = "/var/empty/";
      description = "smb guest account";
      shell = "/run/current-system/sw/bin/nologin";
    };
    users.lena = {
      isNormalUser = true;
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    nsswins = true;
    settings = {
      global = {
        security = "user";
        "mdns name" = "mdns";
        "smb encrypt" = "required";
        "writable" = "yes";
        "browseable" = "yes";
      };
      "marie" = {
        path = "/srv/shares/marie";
        "create mask" = "0644";
        "directory mask" = "0700";
        "valid users" = "marie";
      };
      "lena" = {
        path = "/srv/shares/lena";
        "create mask" = "0644";
        "directory mask" = "0700";
        "valid users" = "lena";
      };
      "media" = {
        path = "/srv/shares/media";
        "create mask" = "0664";
        "directory mask" = "2770";
        "valid users" = "@media";
      };
      "public" = {
        path = "/srv/shares/public";
        "create mask" = "0666";
        "directory mask" = "2777";
      };
    };
  };

  systemd.services.samba-smbd.unitConfig = {
    RequiresMountsFor = [
      "/srv/shares"
      "/srv/shares/marie"
      "/srv/shares/lena"
      "/srv/shares/media"
      "/srv/shares/public"
    ];
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      samba = prev.samba.override {
        enableMDNS = true;
      };
    })
  ];
}
