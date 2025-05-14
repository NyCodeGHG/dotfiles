{ pkgs, ... }:
let
  krisp-patcher = pkgs.fetchurl {
    url = "https://github.com/keysmashes/sys/raw/25f9bc04e6b8d59c1abb32bf4e7ce8ed8de048e2/hm/discord/krisp-patcher.py";
    hash = "sha256-h8Jjd9ZQBjtO3xbnYuxUsDctGEMFUB5hzR/QOQ71j/E=";
  };
  python = pkgs.python3.withPackages (p: with p; [
    capstone
    pyelftools
  ]);
in
{
  systemd.user.services.krisp-patcher = {
    wantedBy = [ "default.target" ];
    path = [ python pkgs.fd ];
    script = ''
      fd '^discord_krisp.node$' ~/.config/discord --exec python ${krisp-patcher}
    '';
  };
}
