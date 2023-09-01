{ lib, pkgs, config, self, ... }:
let
  cfg = config.services.traewelling;
in
{
  options.services.traewelling = {
    enable = lib.mkEnableOption "traewelling";

    user = lib.mkOption {
      type = lib.types.str;
      default = "traewelling";
      description = lib.mdDoc ''
        User account under which traewelling runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the traewelling application starts.
        :::
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;

    };
  };
}
