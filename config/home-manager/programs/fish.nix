{ config, lib, ... }: {
  options.uwumarie.profiles.fish = lib.mkEnableOption "fish profile";
  config = lib.mkIf config.uwumarie.profiles.fish {
    programs.fish.enable = true;
  };
}
