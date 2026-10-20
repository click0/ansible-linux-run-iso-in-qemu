# Changelog

All notable changes to this role are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/) with plain `X.Y.Z` git tags
(the tag is the version imported by Ansible Galaxy).

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

[1.2.1]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.3...1.2.1
[1.0.3]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/releases/tag/1.0.0
