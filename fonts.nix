{pkgs, ...}: {
  packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override {fonts = ["JetBrainsMono" "Iosevka" "IBMPlexMono"];})
  ];
  monospace = ["Blex Mono Nerd Font"];
  sansSerif = ["Noto Sans"];
  serif = ["Noto Serif"];
  emoji = ["Noto Color Emoji"];
}
