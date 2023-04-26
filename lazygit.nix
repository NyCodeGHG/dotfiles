{ pkgs, config, ... }:
let
  theme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/lazygit/c98d9851191fb4c1c31da2fad054210351c65a27/themes/mocha.yml";
    sha256 = "sha256:d96d78c869b5db24a894937f51374381089c46041a87887e67aab12e3d5480c5";
  };
in
  {
    programs.lazygit = {
      enable = true;
      settings = rec theme {
        gui = {
	  showIcons = true;
	};
      };
    };
  }
