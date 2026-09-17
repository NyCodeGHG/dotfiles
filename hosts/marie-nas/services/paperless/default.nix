{
  services.paperless = {
    enable = true;
    settings = {
      PAPERLESS_URL = "https://paperless.marie.cologne";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_ENABLE_COMPRESSION = false;
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;
    };
    configureNginx = true;
    domain = "paperless.marie.cologne";
    database.createLocally = true;
  };
}
