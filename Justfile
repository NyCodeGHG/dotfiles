alias s := switch
hostname := `hostname`

switch:
	sudo nixos-rebuild switch --flake .#{{hostname}}
