{
  pkgs,
  lib,
  config,
  ...
}:
let
  useInsecure = false;
  useStaging = false;
in
{
  systemd.services.fritz-tls = {
    description = "Renew Fritz!Box TLS Certificate";
    documentation = [ "https://github.com/tisba/fritz-tls" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    confinement = {
      enable = true;
      binSh = null;
    };
    environment.TZ = config.time.timeZone;
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      ExecStart = lib.concatStringsSep " " (
        [
          (lib.getExe pkgs.fritz-tls)
          "--host https://tlsautomation@fritzbox.home.marie.cologne"
          "--password-file %d/fritz-password"
          "--dns-provider cloudflare"
        ]
        ++ lib.optional useInsecure "--insecure"
        ++ lib.optional useStaging "--acme-server https://acme-staging-v02.api.letsencrypt.org/directory"
      );
      EnvironmentFile = config.age.secrets.cloudflare-api-key.path;
      LoadCredential = "fritz-password:${config.age.secrets.fritz-password.path}";

      BindReadOnlyPaths = [
        "${config.environment.etc."resolv.conf".source}:/etc/resolv.conf"
        "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
      ];
      CapabilityBoundingSet = "";
      InaccessiblePaths = [ "+/dev/shm" ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateIPC = true;
      PrivateTmp = "disconnected";
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = "strict";
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictNetworkInterfaces = [
        "lo"
        "br0"
      ];
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      SystemCallErrorNumber = "EPERM";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
        "~memfd_create"
      ];
      UMask = "0077";
    };
  };
  systemd.timers.fritz-tls = {
    description = "Renew Fritz!Box TLS Certificate";
    wantedBy = [ "timers.target" ];
    unitConfig."X-OnlyManualStart" = true;
    timerConfig = {
      OnCalendar = "daily";
      FixedRandomDelay = true;
      Persistent = true;
      RandomizedDelaySec = "24h";
    };
  };

  age.secrets.fritz-password.file = ./fritz-password.age;

  environment.etc."alloy/fritz-tls.alloy".source = ./fritz-tls.alloy;
}
