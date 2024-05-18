# SPDX-License-Identifier: Apache-2.0
# File source: https://github.com/K900/vscode-remote-workaround/blob/142aeb19b344bc21ed74aa18c9868ae65bc1759a/vscode.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vscode-remote-workaround;
in {
  options.vscode-remote-workaround = {
    enable = lib.mkEnableOption "automatic VSCode remote server patch";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs_18;
      defaultText = lib.literalExpression "pkgs.nodejs-18_x";
      description = lib.mdDoc "The Node.js package to use. You generally shouldn't need to override this.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      paths.vscode-remote-workaround = {
        wantedBy = ["default.target"];
        pathConfig.PathChanged = "%h/.vscode-server/bin";
      };

      services.vscode-remote-workaround.script = ''
        for i in ~/.vscode-server/bin/*; do
          if [[ -d $i ]]; then
            echo "Fixing vscode-server in $i..."
            ln -sf ${cfg.package}/bin/node $i/node
          fi
        done
      '';
    };
  };
}
