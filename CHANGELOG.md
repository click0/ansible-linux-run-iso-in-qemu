# Changelog

All notable changes to this role are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/) with plain `X.Y.Z` git tags
(the tag is the version imported by Ansible Galaxy).

## [1.2.0] - unreleased

### ⚠ BREAKING

- `lisoq_qemu_enable` is now enforced. Its default is `false`, so QEMU is no longer started unless
  `lisoq_qemu_enable: true` is set (both README examples already set it).
- Disks in use by the host (mounted, swap, LVM/md members) are no longer passed to QEMU.
  Autodetected ones are skipped with a message; explicitly listed ones fail the play.
  Set `lisoq_qemu_disk_allow_in_use: true` to restore the old behaviour.
- `min_ansible_version` is 2.15. EL6 is no longer supported; for EL7 targets use ansible-core 2.15 or 2.16.
  Stay on `1.1.x` if you need older Ansible or EL6.

### Added

- `lisoq_qemu_disk_allow_in_use` (default `false`).

## [1.1.0] - unreleased

### Changed

- Requires the `ansible.posix` collection >= 1.5.0 (`state: ephemeral` mounts).
- With static QEMU and a disk larger than 2 TiB, the downloaded UEFI firmware is now passed to QEMU (`-bios uefi.bin`).

### Fixed

- Re-running the role no longer starts a second QEMU on the same disks and ports.
- Firewall ACL rules are inserted at the top of `INPUT`, so earlier `ACCEPT` rules cannot bypass them.
- Role tmpfs ramdisks are no longer written to `/etc/fstab` (on an installed system the package cache
  came back as a 1 MiB tmpfs after reboot).
- Password-based uploads work with current inventory variables (`ansible_host`, `ansible_port`, `ansible_user`,
  `ansible_password`), respect a non-default SSH port, and upload a symlinked ISO as a file.

## [1.0.4] - unreleased

### Fixed

- The role works again on ansible-core 2.16+: the removed `include` action is replaced with `include_tasks`.
- The role works on ansible-core 2.19+: all `when:` conditions now return a boolean
  (`| bool` for flags, `is truthy`/`is falsy` for paths, URLs, ports and lists).
- Pre-install steps no longer call `apt-get` on RedHat/CentOS hosts.
- `lisoq_iso_file_remote` now attaches the ISO (`-cdrom`) and is cleared when `lisoq_iso_file_local` is set.
- `lisoq_qemu_cpu` set by the user is respected; autodetection applies only when it is empty.
- The UEFI archive download no longer fails on the `lenght` typo, and is triggered when *any* disk exceeds 2 TiB.
- The VNC port is compared as a number (e.g. `10000` is no longer reset to `5901`).
- The package cache size on RedHat is converted from KiB to MiB correctly.
- The CPU vendor check for nested virtualization now actually checks the vendor.
- Removed the self-referencing `lisoq_total_need_ram` from `vars/*.yml`.
- Removed `debugger: on_failed`, which hung non-interactive runs.
- `zram` devices (compressed RAM swap) are no longer passed to QEMU as disks:
  `zram` is added to `lisoq_qemu_exclude_disk_regular_list`.

### Security

- The SSH password is passed to `sshpass` via the `SSHPASS` environment variable instead of the
  command line, and the upload tasks are marked `no_log`.

## [1.0.3] - 2024-02-01

## [1.0.2] - 2023-11-29

## [1.0.1] - 2023-01-22

## [1.0.0] - 2022-09-20

[1.2.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.4...1.1.0
[1.0.4]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/releases/tag/1.0.0
