#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl nix-update

LATEST=$(
  curl -fSL "https://people.freedesktop.org/~aplattner/nvidia-versions.txt" \
    | grep -E '^current[[:space:]]+official' \
    | awk '{ print $3 }'
)

echo "Latest version is $LATEST"
nix-update nixosConfigurations.marie-desktop.config.hardware.nvidia.package \
  --version="$LATEST" \
  --flake \
  --override-filename=hosts/marie-desktop/nvidia.nix \
  "$@"

