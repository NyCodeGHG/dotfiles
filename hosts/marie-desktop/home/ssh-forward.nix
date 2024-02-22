{ pkgs, config, lib, ... }:
{
  options.uwumarie.services.ssh-forwarding.enable = lib.mkEnableOption "wsl ssh-agent forwarding";
  config = lib.mkIf config.uwumarie.services.ssh-forwarding.enable {
    systemd.user.services."ssh-agent@" = {
      Service = {
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p /mnt/c/wsl/"
          "${pkgs.coreutils}/bin/install ${pkgs.pkgsCross.mingwW64.windows.npiperelay}/bin/npiperelay.exe /mnt/c/wsl/npiperelay.exe"
        ];
        ExecStart = "/mnt/c/wsl/npiperelay.exe -ei -s '//./pipe/openssh-ssh-agent'";
        StandardInput = "socket";
      };
      Install.WantedBy = [ "default.target" ];
    };
    systemd.user.sockets.ssh-agent = {
      Install.WantedBy = [ "sockets.target" ];
      Socket = {
        ListenStream = [ "%t/ssh-agent" ];
        Accept = true;
      };
    };
    services.ssh-agent.enable = false;
    home.sessionVariablesExtra = ''
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
      fi
    '';
  };
}
