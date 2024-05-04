{ lib, pkgs, config, ... }:
let
  upload-to-cachix = pkgs.writeScript "upload-to-cachix" ''
    #!${pkgs.runtimeShell}
    export CACHIX_AUTH_TOKEN=$(${lib.getExe' config.systemd.package "systemd-creds"} cat cachix-auth-token)
    "${lib.getExe pkgs.cachix}" push uwumarie $1
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
        --property LoadCredential="cachix-auth-token:${config.age.secrets.cachix-auth-token.path}" \
        --property CollectMode=inactive \
        ${upload-to-cachix} $1
    }

    packagesToUpload=("mongodb" "hello" "lix")

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
  age.secrets.cachix-auth-token.file = ./cachix-auth-token.age;
  services.hydra = {
    enable = true;
    notificationSender = "hydra@localhost";
    hydraURL = "https://hydra.marie.cologne";
    port = 4000;
    useSubstitutes = true;
  };
  nix.settings.post-build-hook = spawn-cachix-upload;
  # nix.buildMachines = [{
  #   hostName = "warpgate.jemand771.net";
  #   system = "x86_64-linux";
  #   sshUser = "marie:gitlabber";
  #   sshKey = "/root/.ssh/id_ed25519";
  #   publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUN1MzJqZlVrTGxUWk1GQTdKWEcybmlBOGR2UThSSUpPODRmMlNHczZiaUIgcm9vdEBnaXRsYWJiZXIK";
  #   protocol = "ssh-ng";
  # }];
  services.nginx.virtualHosts."hydra.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
      proxyWebsockets = true;
    };
  };
}
