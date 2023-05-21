alias s := switch
hostname := `hostname`

switch:
	sudo nixos-rebuild switch --flake .#{{hostname}}

build:
	sudo nixos-rebuild build --flake .#{{hostname}}

deploy-artemis:
  nix run .#apps.nixinate.artemis
