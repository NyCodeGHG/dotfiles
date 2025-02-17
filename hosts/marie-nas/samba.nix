{ ... }:
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
}
