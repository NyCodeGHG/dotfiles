#!/usr/bin/env bash

if [[ -z "$1" ]]; then
  echo "Usage: boot-nixos-generation <generation-file>"
  exit 1
fi

generation="$1"

kernel="/boot/$(rg '^linux (.+\.efi)' -or '$1' $generation)"
initrd="/boot/$(rg '^initrd (.+\.efi)' -or '$1' $generation)"
options="$(rg '^options (.+)' -or '$1' $generation)"
machine_id="$(rg '^machine-id (.+)' -or '$1' $generation)"

options="$options systemd.machine_id=$machine_id"

qemu-kvm -smp 2 -m 4096 -kernel "$kernel" -initrd "$initrd" -append "$options"
