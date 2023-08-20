{ lib, config, ... }:
{
  options.uwumarie = {
    locale = lib.mkOption {
      type = lib.types.str;
      default = "de_DE.utf8";
      description = "The default locale to use";
    };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "The default time zone to use";
    };
  };
  config =
    let
      locale = config.uwumarie.locale;
      timezone = config.uwumarie.timezone;
    in
    {
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
