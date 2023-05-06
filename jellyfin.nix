{ pkgs, config, lib, ... }:
let
  jellyfin-web = pkgs.jellyfin-web.overrideAttrs
    (final: previous: {
      version = "10.8.10";
      src = pkgs.fetchFromGitHub {
        owner = "ConfusedPolarBear";
        repo = "jellyfin-web";
        rev = "4d9c94b8f109435b68ea864bcea3bc41dfceb128";
        sha256 = "sha256-8oVT687/VzSxKx+b9i/PNDFxqIDJn7NeAGQreygVz7E=";
      };
    });
  jellyfin = pkgs.jellyfin.override { inherit jellyfin-web; };
in
{
  services.jellyfin = {
    enable = true;
    package = jellyfin;
    openFirewall = true;
  };
}
