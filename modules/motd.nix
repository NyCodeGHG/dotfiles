{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.uwumarie.services.motd;
  certs = lib.attrsets.mapAttrs
    (name: value: value.directory + "/cert.pem")
    config.security.acme.certs;
in
{
  options.uwumarie.services.motd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables the motd.
      '';
    };
    certificates = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Show Certificates generated via ACME.
        '';
      };
      sort = mkOption {
        type = types.enum [ "alphabetical" "manual" "expiration" ];
        default = "alphabetical";
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (self: super: {
        rust-motd = super.rust-motd.overrideAttrs (old: {
          src = self.fetchFromGitHub {
            owner = "rust-motd";
            repo = "rust-motd";
            rev = "b8fa761ba5722cb9605741c363a307f01f77d0fa";
            sha256 = "sha256-9ti1i5jS9fDr8P3cl+MzYXCsDnihkxrG6x8LFLPoaJA=";
          };
        });
      })
    ];
    programs.rust-motd = {
      enable = true;
      refreshInterval = "*:0/5"; # Every 5 minutes starting from minute 0.
      settings = mkMerge
        [
          {
            global = {
              progress_full_character = "=";
              progress_empty_character = "=";
              progress_prefix = "[";
              progress_suffix = "]";
              time_format = "%Y-%m-%d %H:%M:%S";
            };
            banner = {
              color = "magenta";
              command = "hostname | figlet -f slant";
            };
            uptime = {
              prefix = "Uptime";
            };
            filesystems = builtins.mapAttrs (name: value: value.mountPoint) config.fileSystems;
            memory = {
              swap_pos = "none";
            };
          }
          (mkIf cfg.certificates.enable {
            ssl_certificates = {
              sort_method = cfg.certificates.sort;
              inherit certs;
            };
          })
        ];
    };
    systemd.services.rust-motd = {
      path = with pkgs; [ figlet hostname ];
      serviceConfig = mkMerge [
        {
          RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        }
        (mkIf cfg.certificates.enable {
          ProtectHome = mkForce true;
          User = "rust-motd";
        })
      ];
    };
    users.users.rust-motd = {
      isSystemUser = true;
      group = "rust-motd";
      extraGroups = mkIf cfg.certificates.enable [ "acme" ];
    };
    users.groups.rust-motd = { };
  };
}
