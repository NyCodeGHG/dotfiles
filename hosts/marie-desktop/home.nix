{ config, inputs, pkgs, ... }:
{
  imports = [
    ../../modules/hm/switch-to-windows.nix
  ];
  home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim ];
  news.display = "silent";
  uwumarie.profiles = {
    eza = true;
    git = {
      enable = true;
      # signingKey = "id_ed25519";
      signingKey = null;
      enableGitEmail = true;
    };
    jujutsu = true;
    ripgrep = true;
    ssh = {
      enable = true;
      githubKeyFile = "~/.ssh/id_ed25519";
      defaultKeyFile = "~/.ssh/id_ed25519";
    };
    fish = true;
    tmux = true;
  };
  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/agenix.ed25519"
  ];
  programs.switch-to-windows.enable = true;

  programs.atuin = {
    enable = true;
    settings = {
      sync_address = "https://atuin.marie.cologne";
      sync.records = true;
    };
  };

  # OpenComposite
  # For WiVRn:
#   xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
# 
#   xdg.configFile."openvr/openvrpaths.vrpath".text = ''
#   {
#     "config" :
#     [
#       "${config.xdg.dataHome}/Steam/config"
#     ],
#     "external_drivers" : null,
#     "jsonid" : "vrpathreg",
#     "log" :
#     [
#       "${config.xdg.dataHome}/Steam/logs"
#     ],
#     "runtime" :
#     [
#       "${pkgs.opencomposite}/lib/opencomposite"
#     ],
#     "version" : 1
#   }
#   '';
}
