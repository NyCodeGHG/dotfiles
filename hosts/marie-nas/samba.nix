{ pkgs, ... }:
{
  systemd.tmpfiles.settings.samba-shares = {
    "/srv/shares/marie".d = {
      group = "users";
      user = "marie";
      mode = "0700";
    };
    "/srv/shares/media".d = {
      group = "media";
      user = "root";
      mode = "2770";
    };
  };
  users = {
    groups.media = { };
    users.marie.extraGroups = [ "media" ];
  };

  services.samba = {
    enable = true;
    package = pkgs.samba4Full;
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
      "media" = {
        path = "/srv/shares/media";
        "create mask" = "0664";
        "directory mask" = "0770";
        "valid users" = "@media";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
