{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    go-tools
    gopls
    delve
  ];
}
