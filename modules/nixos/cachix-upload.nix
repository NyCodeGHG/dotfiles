{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.uwumarie.cachix-upload;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  upload-to-cachix = pkgs.writeScript "upload-to-cachix" ''
    #!${pkgs.runtimeShell}
    export CACHIX_AUTH_TOKEN=$(${lib.getExe' config.systemd.package "systemd-creds"} cat cachix-auth-token)
    "${lib.getExe pkgs.cachix}" push ${cfg.cache} $1
  '';
  spawn-cachix-upload = pkgs.writeScript "spawn-cachix-upload" ''
    #!${pkgs.runtimeShell}
    set -euf

    function uploadToCachix() {
      echo "Uploading $package to Cachix"
      ${lib.getExe' config.systemd.package "systemd-run"} \
        --unit "upload-to-cachix-$(date +%s%3N)" \
        --property User=cachix \
        --property Group=cachix \
        --property DynamicUser=true \
        --property LoadCredential="cachix-auth-token:${cfg.cachixTokenFile}" \
        --property CollectMode=inactive \
        ${upload-to-cachix} $1
    }

    packagesToUpload=(${lib.escapeShellArgs cfg.packages})

    for package in $OUT_PATHS
    do
        package_name=$(${lib.getExe config.nix.package} derivation show "$package" | ${lib.getExe pkgs.jq} -r '.[].env.pname')
        for packageToUpload in "''${packagesToUpload[@]}"
        do
            if [[ "$package_name" == "$packageToUpload" ]]; then
              uploadToCachix "$package"
            fi
        done
    done
  '';
in
{
  options.uwumarie.cachix-upload = {
    enable = mkEnableOption "Nix post build hook cachix upload";
    packages = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    cachixTokenFile = mkOption {
      type = types.path;
      description = "Path to a cachix auth token file";
    };
    cache = mkOption {
      type = types.str;
      description = "Cachix cache to upload to";
    };
  };

  config = mkIf cfg.enable {
    nix.settings.post-build-hook = spawn-cachix-upload;
  };
}
