alias s := switch
hostname := `hostname`

switch:
	sudo nixos-rebuild switch --flake .#{{hostname}}

build:
	sudo nixos-rebuild build --flake .#{{hostname}}
