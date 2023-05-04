#!/usr/bin/env bash
set -e

HOSTNAME=$(hostname)
if [[ ! -d ./hosts/$HOSTNAME ]]; then
  echo "Invalid hostname $HOSTNAME."
  exit 1
fi

FILE="./hosts/$HOSTNAME/hardware.nix"
nixos-generate-config --show-hardware-config > $FILE
nix fmt $FILE
