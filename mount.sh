#!/usr/bin/env bash

mount -m /dev/disk/by-id/usb-General_UDisk-0:0-part1 /encryption-keys
cryptsetup open /dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S466NB0K428706Z_1-part3 root --key-file /encryption-keys/root.key
zpool import -N zroot
mount -t zfs zroot/local/root /mnt
mount -t zfs zroot/local/nix /mnt/nix
mount -t zfs zroot/data/state /mnt/state
mount /dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S466NB0K428706Z-part1 /mnt/boot
