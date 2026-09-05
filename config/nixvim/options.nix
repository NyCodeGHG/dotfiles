{ lib, ... }:
{
  options.uwumarie.vscode = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
}
