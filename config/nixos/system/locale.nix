{ config, lib, pkgs, inputs, ... }:
{
  options.uwumarie.profiles.locale = lib.mkEnableOption (lib.mdDoc "The locale config") // {
    default = true;
  };
  config =
  let
    timezone = "Europe/Berlin";
    locale = "de_DE.utf8";
  in lib.mkIf config.uwumarie.profiles.locale {
    time.timeZone = timezone;
    i18n.defaultLocale = locale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  };
}
