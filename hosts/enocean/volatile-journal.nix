{
  services.journald = {
    storage = "volatile";
    extraConfig = "SystemMaxUse=25M";
  };
}
