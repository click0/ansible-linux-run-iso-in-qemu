# Changelog

All notable changes to this role are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/) with plain `X.Y.Z` git tags
(the tag is the version imported by Ansible Galaxy).

## [Unreleased] - planned 1.0.4

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

### Security

- The SSH password is passed to `sshpass` via the `SSHPASS` environment variable instead of the
  command line, and the upload tasks are marked `no_log`.

## [1.0.3] - 2024-02-01

## [1.0.2] - 2023-11-29

## [1.0.1] - 2023-01-22

## [1.0.0] - 2022-09-20

[Unreleased]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.3...HEAD
[1.0.3]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/click0/ansible-linux-run-iso-in-qemu/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/click0/ansible-linux-run-iso-in-qemu/releases/tag/1.0.0
