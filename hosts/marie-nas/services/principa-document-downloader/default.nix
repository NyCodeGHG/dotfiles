{
  inputs,
  config,
  lib,
  ...
}:
let
  secrets = {
    ntfy_url = ./secrets/ntfy_url.age;
    paperless_base_url = ./secrets/paperless/base_url.age;
    paperless_token = ./secrets/paperless/token.age;
    principa_base_url = ./secrets/principa/base_url.age;
    principa_context = ./secrets/principa/context.age;
    principa_password = ./secrets/principa/password.age;
    principa_user = ./secrets/principa/user.age;
  };
in
{
  imports = [
    inputs.principa-document-downloader.nixosModules.default
  ];
  services.principa-document-downloader = {
    enable = true;
    secrets = lib.genAttrs (lib.attrNames secrets) (secret: config.age.secrets.${secret}.path);
    startAt = "Mon..Fri 9..17/2:00:00";
  };

  age.secrets = lib.mapAttrs (_: secret: { file = secret; }) secrets;
}
