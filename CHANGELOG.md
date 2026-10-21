# Changelog

All notable changes to this role are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/) with plain `X.Y.Z` git tags
(the tag is the version imported by Ansible Galaxy).

## [Unreleased]

### Changed

- Autodetected disks are passed to QEMU in name order (before: in the order the kernel listed them, which could
  change between runs). ZFS zvols (`zd*`) and `bcache*` devices are excluded from autodetection.

- If IPv6 is enabled but `ip6tables` does not work, the firewall step fails instead of setting IPv4 rules only
  (QEMU's VNC with `lisoq_qemu_vnc_type: share` also listens on IPv6).

### Fixed

- Changing the port settings while the QEMU of the role is running (it is not restarted) no longer opens the
  ports it still listens on: they stay in the firewall ACL until it is stopped.
- The firewall ACL is updated without a window in which the ports are open (new rules are added before the old
  ones are removed), and an unchanged ACL no longer reports changes on every run.
- Uploads with a password as a non-root `ansible_user` (README Example #2 with become) failed with "Permission
  denied": the work directory was private to root. It is now owned by `ansible_user` in this case.
- Extracting the QEMU/UEFI archives no longer changes the owner and mode of the work directory (both default
  archives contain a `./` entry); with a custom archive packed by a normal user the next run refused to continue.
- Check mode no longer fails on a host without the work directory (the ISO download and the archive extraction
  are skipped), and no longer uploads `lisoq_qemu_static_custom_local` as a file named like the work directory.
- `lisoq_qemu_disk` given as a string (`'sda'`, `'sda,sdb'`) was split into single characters; names with `/dev/`
  work too.
- Partitions (or other devices missing from `ansible_devices`) in `lisoq_qemu_disk` failed the 2 TiB check.
- A message is printed when no disks are passed to QEMU.
- Hosts of other OS families are skipped with a message (as the per-OS task files intended) instead of failing
  on a missing vars file.
- The first step no longer runs `apt-get update` and reports "changed" on every run when `python3-apt` is already
  installed.
- A `-name` in `lisoq_qemu_args` no longer hides the running VM from the role (a re-run started a second QEMU on
  the same disks): `-name lisoq` now comes after `lisoq_qemu_args`.
- Password-based uploads work with paths containing spaces also with rsync older than 3.2.4 on the control node.
- The password-based uploads report "changed" only when a file was actually transferred.
- `lisoq_firewall_acl_enable: false` removes the `LISOQ_QEMU` chain left by an earlier run; before, the old
  whitelist was enforced until reboot.

- The ramdisk is no longer mounted on top of `lisoq_ramdisk_path` when a filesystem is mounted below it
  (e.g. a server disk on `/mnt/data`): that hid the disk's files. `lisoq_ramdisk_another_path` is used instead.

## [1.5.0] - 2026-10-21

### ⚠ Changed

- Disks with an active md array, LVM, dm-crypt/multipath device, or in an imported ZFS pool are treated as in use
  and not passed to QEMU (before, only mounted disks and swap were; the 1.2.1 entry already claimed LVM/md).
  On rescue systems that auto-assemble md arrays, stop them first (`mdadm --stop --scan`) or set
  `lisoq_qemu_disk_allow_in_use: true`.
- The firewall ACL lives in its own chain `LISOQ_QEMU`, rebuilt on every run; INPUT only jumps to it.
- Files of the role (ISO, QEMU archives, `uefi.bin`, uploads) are kept in `<ramdisk path>/lisoq`, a private
  directory; the role refuses to reuse it if another user could have prepared it. Files from older versions in
  the ramdisk path itself are downloaded once more.
- The role's QEMU is started with `-name lisoq`.

### Fixed

- Servers with 4 disks (plus the ISO) or more could not start QEMU ("machine type does not support
  if=ide,bus=2,unit=0"). Disks that do not fit on the IDE bus are attached via AHCI (SATA) controllers.
- Removing an address from the firewall whitelists (or a new address of the Ansible host) now revokes access;
  previously the old ACCEPT rule stayed in place.
- The firewall protects the VNC port QEMU actually listens on (values below 5900 mean 5901); before, e.g.
  `lisoq_qemu_args_port_vnc: '1'` left 5901 open.
- `lisoq_qemu_enable: true` without `lisoq_qemu_install` or static QEMU now fails with a clear message instead of
  silently starting nothing.
- File paths with spaces (e.g. README Example #2) work in the password-based upload and in `-cdrom`.
- Another VM on the host (e.g. from libvirt) no longer prevents the role from starting its own.
- `lisoq_ramdisk_package_purge` unmounts only the package cache tmpfs mounted by the role.
- With the firewall enabled, hosts without IPv6 (ip6tables not working) get IPv4 rules only instead of failing.
- On multi-user hosts another user can no longer plant the QEMU binary or the ISO in the world-writable ramdisk
  path for root to run.

## [1.4.0] - 2026-10-21

First release after 1.2.1. Versions 1.2.2 and 1.3.0 were never tagged; their changes are included here.

### ⚠ Changed

- `lisoq_firewall_acl_enable` is `true` by default. The QEMU forwarded ports (VM SSH 1022, RDP, VNC) were open to
  everyone, and live ISOs such as mfsbsd have a well-known root password. Now they are reachable only from the
  whitelists. Set `lisoq_firewall_acl_enable: false` to restore the old behaviour.
- The default ISO (`lisoq_iso_file_url`) is mfsbsd 14.2 instead of 12.2 (FreeBSD 12 is end-of-life).
  It boots in both BIOS and UEFI mode. Set `lisoq_iso_file_url` explicitly to keep the old image.
- On RedHat the role no longer stops `firewalld` when the ACL is enabled (that removed the filtering of all
  other ports of the server); it prints a warning that `firewall-cmd --reload` drops the ACL rules.

### Added

- `lisoq_firewall_acl_allow_ansible_ip` (default `true`): the address the Ansible control node connects from,
  as seen by the server (`SSH_CONNECTION`), is added to the whitelist automatically.
- `lisoq_qemu_uefi` (default `false`): boot QEMU with the UEFI firmware (`-bios uefi.bin`).
  Requires `lisoq_qemu_static_custom_enable: true` and an ISO with a UEFI boot loader.

### Fixed

- In 1.2.1 static QEMU was started with `-bios uefi.bin` automatically when a disk was larger than 2 TiB,
  so ISOs without a UEFI boot loader (including the previous default mfsbsd 12.2) did not boot at all
  ("Boot Failed. EFI DVD/CDROM"). UEFI is now opt-in; such disks are fully usable in BIOS mode,
  the role only prints a hint about `lisoq_qemu_uefi`.
- The ISO and the static QEMU/UEFI archives are no longer downloaded again on every run
  (the ISO is saved to an explicit file path, the archives are extracted only once).
- `lisoq_qemu_vnc_type` is validated: values other than `local`/`share` used to start QEMU without `-vnc`,
  which fails on a headless server.
- `lisoq_ramdisk_package_purge` no longer leaves a 1 MiB tmpfs on the package cache directory, which broke any
  later package download, including a re-run of the role.

## [1.2.1] - 2026-10-20

First release after 1.0.3. Versions 1.0.4, 1.1.0 and 1.2.0 were never tagged; their changes are included here.

### ⚠ BREAKING

- `lisoq_qemu_enable` is now enforced. Its default is `false`, so QEMU is no longer started unless
  `lisoq_qemu_enable: true` is set (both README examples already set it).
- Disks in use by the host (mounted, swap, LVM/md members) are no longer passed to QEMU.
  Autodetected ones are skipped with a message; explicitly listed ones fail the play.
  Set `lisoq_qemu_disk_allow_in_use: true` to restore the old behaviour.
- `min_ansible_version` is 2.15. EL6 is no longer supported; for EL7 targets use ansible-core 2.15 or 2.16.
  Stay on `1.0.3` if you need older Ansible or EL6.
- Requires the `ansible.posix` collection >= 1.5.0 (`state: ephemeral` mounts).

### Added

- `lisoq_qemu_disk_allow_in_use` (default `false`).

### Changed

- With static QEMU and a disk larger than 2 TiB, the downloaded UEFI firmware is now passed to QEMU (`-bios uefi.bin`).
- Without hardware virtualization (no vmx/svm or /dev/kvm) QEMU runs without KVM instead of failing on modprobe.
- `lisoq_total_need_ram` and `lisoq_ramdisk_package_size`, when set, are used as documented instead of being
  recalculated.

### Fixed

- The role works again on ansible-core 2.16+ (the removed `include` action is replaced with `include_tasks`)
  and on 2.19+ (all `when:` conditions return a boolean).
- Settings passed with `-e`, role params or `include_role` `vars` are applied correctly. The role used to
  rewrite its own input variables with `set_fact`, which has a lower precedence than these sources, so the
  rewrites were silently ignored: e.g. with `-e lisoq_qemu_args=...` QEMU started with only the user's
  arguments (no ISO, RAM, CPU, disks, VNC, port forwarding). Derived values now live in internal
  `__lisoq_*` facts and `lisoq_*` variables are never modified.
- Pre-install steps no longer call `apt-get` on RedHat/CentOS hosts.
- Re-running the role no longer starts a second QEMU on the same disks and ports.
- `lisoq_iso_file_remote` now attaches the ISO (`-cdrom`).
- `lisoq_qemu_cpu` set by the user is respected; autodetection applies only when it is empty.
- The UEFI archive download no longer fails on the `lenght` typo, and is triggered when *any* disk exceeds 2 TiB.
- The VNC port is compared as a number (e.g. `10000` is no longer reset to `5901`).
- `zram` devices (compressed RAM swap) are no longer passed to QEMU as disks.
- Firewall ACL rules are inserted at the top of `INPUT`, so earlier `ACCEPT` rules cannot bypass them.
- Ramdisk path selection: an existing tmpfs is detected (via `findmnt`) and only grown, never shrunk;
  a non-tmpfs mount on `lisoq_ramdisk_path` falls back to `lisoq_ramdisk_another_path`.
- Role tmpfs ramdisks are no longer written to `/etc/fstab` (on an installed system the package cache
  came back as a 1 MiB tmpfs after reboot).
- Re-running with `lisoq_ramdisk_package_enable` no longer fails with "Device or resource busy".
- The package cache size on RedHat is converted from KiB to MiB correctly.
- Password-based uploads work with current inventory variables (`ansible_host`, `ansible_port`, `ansible_user`,
  `ansible_password`), respect a non-default SSH port, and upload a symlinked ISO as a file.
- Removed `debugger: on_failed`, which hung non-interactive runs.

### Security

- The SSH password is passed to `sshpass` via the `SSHPASS` environment variable instead of the
  command line, and the upload tasks are marked `no_log`.

## [1.0.3] - 2024-02-01

## [1.0.2] - 2023-11-29

## [1.0.1] - 2023-01-22

## [1.0.0] - 2022-09-20

[Unreleased]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.5.0...HEAD
[1.5.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.2.1...1.4.0
[1.2.1]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.3...1.2.1
[1.0.3]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/releases/tag/1.0.0
