---
name: nixos-vm
description: Boot a NixOS configuration in a throwaway QEMU VM and get a root shell in it over SSH-on-vsock, to debug, inspect or troubleshoot how the system actually behaves at runtime. Use this whenever a question about a NixOS config can only be answered by running it - a service that fails to start, a unit ordering or boot problem, checking which files/users/permissions/firewall rules a module really produces, reproducing a bug from a host without touching that host, or trying out a module or option change before deploying it - even if the user never says "VM". Covers building via `nixos-rebuild build-vm` / `pkgs.nixos` / flake `nixosConfigurations`, provisioning the user's SSH key through a systemd credential, connecting with `ssh vsock%<CID>`, and shutting down and cleaning up afterwards.
---

# Debugging NixOS configurations in a VM

A NixOS VM built from the configuration under investigation is the cheapest way to see
what that configuration really does: services start for real, the journal is there,
and nothing on a real host is touched. The VM shares the host's `/nix/store`, so
building it only builds the system closure, and it boots in seconds.

Before booting anything, ask whether evaluation already answers the question - the
value of an option, the content of a generated config file or unit, or whether the
config builds at all can be read with `nix eval` / `nix-instantiate --eval` or by
building `config.system.build.toplevel` and reading the files. Boot a VM when you need
runtime behaviour.

Use an interactive VM for investigation, not a NixOS test (`runNixOSTest`,
`nixosTest`). A test makes you guess every command up front, and each follow-up
question costs another rebuild and reboot. A running VM lets you look around, follow
whatever the journal shows, and try things as you go. Write a NixOS test only when
the user asks for one, for example to keep a regression covered once the cause is
known.

## How access works

- The guest runs OpenSSH (`services.openssh.enable = true`). With that enabled,
  `systemd-ssh-generator` in the guest notices the vsock device and adds an sshd
  listener on `AF_VSOCK` port 22 - independent of guest networking or firewall.
- QEMU gets `-device vhost-vsock-pci,guest-cid=<CID>`. The CID is the guest's vsock
  address; it must be unique among running VMs on the host (>= 3).
- The user's public key(s) are passed as the systemd credential
  `ssh.authorized_keys.root` through an SMBIOS type 11 string. The NixOS openssh
  module has a tmpfiles rule that writes that credential to
  `/root/.ssh/authorized_keys` at boot. No keys or passwords end up in the Nix store
  or the configuration.
- On the host, `systemd-ssh-proxy` (included from the system `ssh_config` on NixOS)
  handles host names `vsock%<CID>`: it defaults to `User root` and disables host key
  checking, since these guests are ephemeral. `ssh vsock%<CID>` is all that's
  needed. Prefer `%` over the equivalent `vsock/<CID>` form because `scp`/`rsync`
  would treat the `/` as a path separator.

## 1. Prepare a working directory and a debug module

Put everything that belongs to one VM into its own fresh temporary directory. Don't
use the user's repo, their home directory, or the current directory: by default the
VM run script drops a `<hostname>.qcow2` into `$PWD`.

```sh
CID=$(shuf -i 3-4294967294 -n 1)
VMDIR=$(mktemp -d "${TMPDIR:-/tmp}/nixos-vm.XXXXXX")
```

Keep the path short. That rules out a deeply nested scratchpad directory. The run
script creates virtiofsd sockets in a `mktemp -d` below `$VMDIR`, and a Unix socket
path must stay under 108 bytes. If it is longer, QEMU exits immediately with
`UNIX socket path ... is too long`.

Shell variables don't survive between separate tool calls. Note the literal CID and
`$VMDIR` and reuse them in every later command.

Don't edit the user's configuration to make it debuggable. Write the VM-only bits into
a separate module in `$VMDIR` and add it on top. Everything under
`virtualisation.vmVariant` applies only to the VM build, not to the real system:

```nix
# $VMDIR/vm-debug.nix
{
  virtualisation.vmVariant = {
    services.openssh.enable = true;
    # serial console on stdout instead of opening a window on the user's desktop
    virtualisation.graphics = false;
    # adjust if the services under test need it (defaults: 1024 MiB, 1 core)
    # virtualisation.memorySize = 4096;
    # virtualisation.cores = 4;
  };
}
```

Add whatever else the investigation needs to this module (extra packages for
debugging, a changed option you want to try out, ...).

### Disk image or tmpfs root

Decide up front whether the guest's state has to survive a reboot. By default the VM
keeps its root filesystem (everything except the store: `/var`, `/etc`, `/root`, ...) in
a qcow2 disk image. You need that only if the investigation reboots the guest and
looks at what is left afterwards: first-boot versus second-boot behaviour, data a
service must persist, migrations between two generations.

Most debugging doesn't need it. Then put the root on a tmpfs instead by adding this to
the `vmVariant` in `vm-debug.nix`:

```nix
    # root on tmpfs: no disk image, and state is gone after every reboot/restart
    virtualisation.diskImage = null;
```

That way no disk image is created or stored, and every start is a clean first boot.
The tmpfs gets half of the guest's RAM, about 480 MiB with the default 1024 MiB. Raise
`virtualisation.memorySize` if the services under test write a lot to `/var`.

### Network access

By default the guest sits behind QEMU's user-mode NAT and can reach the host and the
internet. For a real host's configuration (a flake `nixosConfigurations.<host>`, or a
config that is deployed somewhere), cut that off:

```nix
    # no outbound network: the guest can't reach the host or the internet
    virtualisation.restrictNetwork = true;
```

A VM of a real host runs that host's services under its name. Given network access, it
may push metrics and logs, register runners, renew certificates, join a VPN or talk to
peers as if it were the real machine, and the user never asked for that. Isolation
doesn't limit the investigation: SSH over vsock doesn't use the guest network. Allow
outbound access only if the question depends on it (for example "why can't this
service reach X"), and tell the user that the VM had network access.

Throwaway test configs written for the task can keep the default network.

## 2. Build the VM

Pick the form that matches how the configuration is defined. Each prints (or, for
nixos-rebuild, ends with) the store path of the VM; its `bin/run-<hostname>-vm` is the
start script. Avoid leaving `result` symlinks behind.

**A plain `configuration.nix`**, with an explicit nixpkgs (use the one the config is
meant to be built with; `<nixpkgs>` from `NIX_PATH` if nothing else is known):

```sh
nix-build --no-out-link -I nixpkgs=<nixpkgs> -E '
  (import <nixpkgs> { }).nixos {
    imports = [ /abs/path/configuration.nix '"$VMDIR"'/vm-debug.nix ];
  }' -A config.system.build.vm
```

or equivalently, with a small wrapper `$VMDIR/configuration.nix` that imports both
files:

```sh
nixos-rebuild build-vm --no-link -I nixos-config="$VMDIR"/configuration.nix -I nixpkgs=<nixpkgs>
```

**A flake `nixosConfigurations.<host>`**: extend the existing configuration with the
debug module:

```sh
nix build --no-link --print-out-paths --impure --expr '
  ((builtins.getFlake "/abs/path/to/flake").nixosConfigurations.<host>.extendModules {
    modules = [ '"$VMDIR"'/vm-debug.nix ];
  }).config.system.build.vm'
```

If the configuration already enables openssh and you don't need anything else, the
plain `nix build --no-link --print-out-paths .#nixosConfigurations.<host>.config.system.build.vm`
works too.

## 3. Start it

Start the VM and wait for SSH in the same command, so the loop can notice right away
if QEMU dies instead of waiting out the timeout:

```sh
VM=<store path from step 2>
KEYS=$(ssh-add -L 2>/dev/null || cat ~/.ssh/id_ed25519.pub)
# only with a disk image; leave this out for a tmpfs root (diskImage = null)
export NIX_DISK_IMAGE="$VMDIR/disk.qcow2"

TMPDIR="$VMDIR" USE_TMPDIR=1 \
QEMU_OPTS="-pidfile $VMDIR/qemu.pid \
  -device vhost-vsock-pci,guest-cid=$CID \
  -smbios type=11,value=io.systemd.credential.binary:ssh.authorized_keys.root=$(printf '%s\n' "$KEYS" | base64 -w0)" \
  setsid "$VM"/bin/run-*-vm </dev/null >"$VMDIR/console.log" 2>&1 &
PID=$!
SECONDS=0
until ssh -o ConnectTimeout=2 -o BatchMode=yes vsock%$CID true 2>/dev/null; do
  kill -0 $PID 2>/dev/null || { echo "VM exited:"; tail -30 "$VMDIR/console.log"; break; }
  [ $SECONDS -gt 180 ] && { echo "no ssh after 180s:"; tail -30 "$VMDIR/console.log"; break; }
  sleep 1
done
```

A minimal configuration is reachable after about 10 seconds.

Why it looks like this:

- The credential is passed base64-encoded (`io.systemd.credential.binary:`) because
  the run script word-splits `$QEMU_OPTS`, and an SSH public key contains spaces.
- `ssh-add -L` provisions exactly the keys ssh will offer; the fallback covers
  users without an agent. Several keys, one per line, are fine.
- `NIX_DISK_IMAGE`, `TMPDIR` and `USE_TMPDIR` keep the disk image and QEMU's runtime
  files (including the `xchg` share) inside `$VMDIR`, so deleting that directory
  cleans up everything. With `diskImage = null`, the run script still creates an
  image if `NIX_DISK_IMAGE` is set, but the guest never uses it, so leave it unset
  there.
- `console.log` holds QEMU's and virtiofsd's messages and the serial console
  (kernel, initrd and systemd boot messages). Read it when the VM doesn't come up.
  `unable to set guest cid: Address already in use` means another VM has the CID.
  Pick a new one and restart.
- `$PID` is QEMU itself: the run script `exec`s it. `$VMDIR/qemu.pid` has the same
  PID for later calls.

## 4. Investigate

Run commands non-interactively, one `ssh` call each.

`systemctl --failed` is not enough to see what's broken. A unit with `Restart=` that
keeps crashing sits in `auto-restart` and never counts as failed. A oneshot with no
timeout that hangs stays `activating` forever and holds up everything ordered after
it, including `multi-user.target`. Look at the overall state as well:

```sh
ssh vsock%$CID 'systemctl is-system-running; systemctl --failed --no-legend; systemctl list-units --all --no-legend --state=activating,auto-restart,auto-restart-queued; systemctl list-jobs --no-legend; journalctl -b --no-pager | grep "Scheduled restart job" | tail'
```

`starting` long after boot, with jobs still waiting, means something is stuck. The
`activating` unit that the waiting jobs depend on is the culprit. A crash-looping unit
keeps changing state and can even look `active (running)` for a moment between two
crashes. So `list-units` can miss it, but the journal's
`Scheduled restart job, restart counter is at N` lines cannot. Then
`systemctl show -p NRestarts,Result <unit>` and the unit's journal tell you why.

```sh
ssh vsock%$CID journalctl -b -u foo.service --no-pager
ssh vsock%$CID systemctl cat foo.service
ssh vsock%$CID 'cat /etc/foo/config; ls -la /var/lib/foo'
```

- Copy files with `scp vsock%$CID:/path/in/guest "$VMDIR"/`. `$VMDIR/xchg` is also
  mounted in the guest as `/tmp/shared`.
- To reach a guest service from the host, forward it over ssh:
  `ssh -N -L 8080:localhost:80 vsock%$CID`.
- Nothing can connect into the guest except over vsock. Outbound access depends on
  `restrictNetwork` (see step 1).

To try a fix: change the module/config, rebuild (step 2), stop the running VM (step 5,
but keep `$VMDIR`), and start the new one. With a tmpfs root, every start is fresh
anyway. With a disk image, delete `disk.qcow2` before restarting unless the old
state matters for the reproduction.

### Where the VM differs from the real host

Keep this in mind before concluding that "it works in the VM":

- `fileSystems` and the boot loader are replaced (root is a fresh disk image or a
  tmpfs, and the store comes from the host). Mount units and disk layout issues won't reproduce.
- Hardware is generic virtio: other NIC names, no GPU, no host-specific devices.
- Secrets that are decrypted with the host's key (agenix, sops-nix using the SSH host
  key) fail to decrypt, since the VM has its own freshly generated host key. Services
  depending on them will fail for that reason alone. Stub them in `vm-debug.nix` if
  they are in the way.
- There's no real network identity: DNS names, static IPs, VPNs, and peers of the
  real host are absent.

## 5. Stop and clean up

Shut the VM down when you're done, including when the investigation is abandoned
partway. A forgotten VM keeps using RAM and its CID in the background.

```sh
PID=$(cat "$VMDIR/qemu.pid")
ssh vsock%$CID poweroff || kill $PID
for i in $(seq 30); do kill -0 $PID 2>/dev/null || break; sleep 1; done
kill -0 $PID 2>/dev/null && echo "QEMU still running" || rm -rf "$VMDIR"
```

The virtiofsd helpers exit by themselves once QEMU is gone. Also remove any `result`
symlink you created along the way.

## Running from Claude Code's Bash sandbox

Building talks to the nix daemon over a Unix socket, the VM needs `/dev/kvm` and
`/dev/vhost-vsock`, and `ssh vsock%...` opens an `AF_VSOCK` socket. The sandbox blocks
all of these ("cannot create Unix domain socket: Operation not permitted", missing
`/dev/kvm`), so those commands have to run outside it. Outside the sandbox `$TMPDIR`
is usually unset, which is why step 1 falls back to `/tmp`.
