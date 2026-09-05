{ lib, config, ... }:
{
  plugins = lib.mkIf (!config.uwumarie.vscode) {
    dap-ui.enable = true;
    dap-virtual-text.enable = true;
    dap = {
      enable = true;
    };
  };
}
