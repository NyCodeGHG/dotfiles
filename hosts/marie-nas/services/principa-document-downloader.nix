{
  inputs,
  config,
  lib,
  ...
}:
let
  secrets = [
    "ntfy_url"
    "paperless_base_url"
    "paperless_token"
    "principa_base_url"
    "principa_context"
    "principa_password"
    "principa_user"
  ];
in
{
  imports = [
    inputs.principa-document-downloader.nixosModules.default
  ];
  services.principa-document-downloader = {
    enable = true;
    secrets = lib.genAttrs secrets (secret: config.age.secrets.${secret}.path);
    startAt = "Mon..Fri 9..17/2:00:00";
  };

  age.secrets = lib.genAttrs secrets (secret: {
    file = ../secrets/${secret}.age;
  });
}
