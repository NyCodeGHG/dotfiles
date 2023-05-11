{ pkgs, config, lib, ... }: {
  services.postgresql = {
    enable = true;
  };
}
