# linux_run_iso_in_qemu

[Ansible Galaxy](https://galaxy.ansible.com/click0/linux_run_iso_in_qemu/)

Linux. Running QEMU with (or without) ISO image and connecting block devices (HDD/SSD) of the host machine.  

Feel free to [share your feedback and report issues](https://github.com/click0/ansible-linux-run-iso-in-qemu/issues).
[Contributions are welcome](https://github.com/firstcontributions/first-contributions).

## Synopsis

Many Datacenters and Hosters have removed the OS installation from their media (ISO image).
And, most generally offer very little choice - Debian, Ubuntu, CentOS and nothing else.
This role will allow you to run the QEMU program with the Rescue server mode.  
[QEMU](https://www.qemu.org/) allows us to emulate a virtual machine, to which we will connect the ISO image as a CD-ROM and connecting block devices (HDD/SSD) of the host machine.
The role uses QEMU of two types - from the package base of the system and universal binary for Linux with statically compiled libraries.
The ISO image can be used as your favorite OS install disk, diagnostic disk, or other live operating system ([Live-CD](https://en.wikipedia.org/wiki/Live_CD))
Sources for obtaining ISO image and QEMU universal binary - local system running Ansible, Rescue server mode itself and ftp/http(s).

The system inside QEMU has Internet access through QEMU user networking (NAT), also when no ports are forwarded.  
To increase security for access to the system in QEMU, you can specify a whitelist of IP/networks through the `iptables` firewall.  

## Requirements

Linux system Debian or CentOS.  
Installed packages on target hosts:
  - python3
  - python3-apt
    
ansible-core 2.15 or newer on the control node (tested with 2.15 and 2.19).
For EL7 targets use ansible-core 2.15 or 2.16: newer versions do not support its Python.
On EL8 and newer only the static QEMU (`lisoq_qemu_static_custom_enable: true`) can be used: there is no
`qemu-system-x86` package, and their `qemu-kvm` supports neither the `pc` machine nor IDE disks.

Ansible collection on the control node:
  - `ansible.posix` >= 1.5.0 (`ansible-galaxy collection install ansible.posix`)

Installed packages on the control node (Ansible):
  - rsync
  - sshpass  
If you use password login to target hosts via `ssh`.
The local files (`lisoq_iso_file_local`, `lisoq_qemu_static_custom_local`) are then uploaded with `rsync` + `sshpass`
as the user Ansible logs in as. Without a password they are uploaded with `ansible.posix.synchronize`, also as that
user and without sudo, so become on the target may ask for a password. The password must be set in a variable (`ansible_password` or `ansible_ssh_pass`):
a password typed with `--ask-pass` is not visible to the role.

## Variables

See the [`defaults/main.yml`](defaults/main.yml) and examples in vars.
All variables can be set in any usual way: inventory, play `vars`/`vars_files`, role `vars` or params,
`include_role` `vars`, or extra vars (`-e`). The role never modifies them; values it derives are kept in
internal `__lisoq_*` facts, so a setting passed with `-e` is applied the same way as one from a vars file.


    lisoq_qemu_enable: false
Whether to start QEMU. With `false` the role still prepares everything (packages, ramdisk, firewall, ISO and QEMU downloads), but does not start QEMU.
**Since 1.2.1** this option is enforced: before 1.2.1 QEMU was started regardless of it, so set `lisoq_qemu_enable: true` explicitly.

    lisoq_qemu_static_custom_enable: false
The option is responsible for using (or not) universal binary for Linux with statically compiled libraries.
If this variable is selected, then the other variable `lisoq_qemu_install` will be disabled by the role itself.

    lisoq_qemu_static_custom_local: ''
The local path on the Ansible host to the statically compiled QEMU archive(tar.gz).

    lisoq_qemu_static_custom_url: 'https://support.org.ua/Soft/vKVM/orig/vkvm.tar.gz'
URL location with the statically compiled QEMU archive(tar.gz).

    lisoq_qemu_static_custom_relative_dir: '/share/qemu/'
Relative path inside the statically compiled QEMU archive to auxiliary files (BIOS, keyboard layout etc).
Leading and trailing slashes are optional; empty means `share/qemu`.

    lisoq_qemu_static_custom_uefi_url: 'https://support.org.ua/Soft/vKVM/orig/uefi.tar.gz'
UEFI firmware archive (`uefi.bin`) used with `lisoq_qemu_uefi: true`.

    lisoq_qemu_uefi: false
Boot QEMU with UEFI firmware (`-bios uefi.bin`) instead of the default BIOS (SeaBIOS). Requires `lisoq_qemu_static_custom_enable: true`.
Enable it only if the OS must be installed or booted in UEFI mode, and only with an ISO that supports UEFI boot
(the default mfsbsd 14.2 ISO does, older mfsbsd 12.x ISOs do not). Disks larger than 2 TiB are fully usable in BIOS mode as well.

    lisoq_qemu_args_port_ssh: '1022'
External port for ssh forwarding to QEMU internal port `22`. Empty: no ssh forwarding.

    lisoq_qemu_args_port_rdp: '3389'
External port for RDP forwarding to internal QEMU port `3389`. Empty: no RDP forwarding.
Without both the VM still has the user network (NAT) and Internet access, only the VNC port is reachable from outside.

    lisoq_qemu_args_port_vnc: '5901'
External port for forwarding VNC to internal QEMU port `5901`

    lisoq_qemu_vnc_type: 'local'
The variable controls how QEMU will "listen" for VNC connections.
The value of the `local` variable is to listen only on `localhost`.
The value of the `share` variable is to listen on all IPs (IPv6 too with newer QEMU, e.g. 10.0; the static
QEMU 2.2 listens on IPv4 only).

    lisoq_qemu_install: false
Install QEMU from the package repository.

    lisoq_qemu_ram: '1024'
How much RAM (in MiB) can you use inside QEMU.

    lisoq_qemu_cpu: '' 
How much CPU core can you use inside QEMU. By default `''` and role allocates all CPU cores for QEMU use,
but at most 255 (the limit of the `pc` machine; QEMU does not start with more).

    lisoq_qemu_disk: ''
List of block disk devices to connect to QEMU. By default, the role passes all block devices found on the host machine
(except `lisoq_qemu_exclude_disk*`, in name order). You can specify your own list of block devices
(a string such as `'sda,sdb'` works too):

    lisoq_qemu_disk:
      - 'sda'
      - 'sdb'
<br>

    lisoq_qemu_disk_allow_in_use: true
By default all selected disks are passed to QEMU, also those in use by the host: the disk or anything on it is mounted
or used as swap, an active md array, LVM volume, dm-crypt/multipath or bcache device sits on it, or it belongs to an
imported ZFS pool or to a mounted btrfs filesystem (also the members of a multi-device btrfs that lsblk shows without a
mount point). The role does not unmount or stop anything on the host; it only prints a warning with these disks.
Writing to such a disk from the host and from QEMU at the same time corrupts it (an active md array writes even when
not mounted, e.g. during a resync), so stop what uses them on the host first. Rescue systems often assemble md arrays
(and activate LVM) automatically: `mdadm --stop --scan`, `vgchange -an`, `zpool export`.
On an installed (not rescue) system the host's own system disk is passed to QEMU as well.
Set to `false` for the safe mode: autodetected disks in use are skipped with a message, and if such a disk is listed
explicitly in `lisoq_qemu_disk`, the role fails.
<br>

    lisoq_qemu_exclude_disk:
      - 'fd0'
      - 'sr0'

List of block disk devices to be excluded from the `lisoq_qemu_disk` list. The exclusion list usually contains FDD and CD-ROM devices.
You can override the variable yourself and add your own block devices to the exclusion list.

    lisoq_qemu_exclude_disk_regular_list:
      - 'fd'
      - 'sr'
      - 'dm-'
      - 'loop'
      - 'ram'
      - 'zram'
      - 'nbd'
      - 'md'
      - 'zd'
      - 'bcache'

A list of block devices without a numeric suffix to be excluded from the list for intra-OS connection in QEMU.
Based on the `lisoq_qemu_exclude_disk_regular_list` variable inside the role, a regular expression will be generated.

    lisoq_qemu_boot_cd: true
Whether to boot QEMU from CD-ROM (from our downloaded ISO image file `lisoq_iso_file_...` ).
If this parameter is set to `false`, then QEMU will try to boot from the first block device specified.

    lisoq_qemu_boot_once_cd: true
Whether to download _**once**_ from CD-ROM (from our downloaded ISO image file `lisoq_iso_file_...` ). 
Inside QEMU, you can choose to `reboot` the virtual machine and then the system will try to boot from the HDDs, _not_ from the CD-ROM.
To use service CDs where there is a large set of applications, and the need to reboot the virtual machine frequently, set the value to `false`.

    lisoq_iso_file_local: ''
Full path to the ISO image file on the host machine from which the Ansible role is run. There is support for symlinks and share partitions mounted on the host machine file system.

    lisoq_iso_file_remote: '' 
ISO image file location path on a remote host.

    lisoq_iso_file_url: 'https://mfsbsd.vx.sk/files/iso/14/amd64/mfsbsd-14.2-RELEASE-amd64.iso'
URL location with ISO image file.

    lisoq_iso_file_ssh_port: '22' 
Sshd port that accepts connections _inside_ ISO image.

    lisoq_checksum_enable: false
    lisoq_iso_file_checksum: 'sha256:2803be01ef284cb4d58c9177475c7a20ac72292e4943bc91eb159c592bfc3b5c'
    lisoq_qemu_static_custom_checksum: 'sha256:a8a7c9236d6d51f806203a719b95b071973c0a9630ad00a0157a4efd78b29f89'
    lisoq_qemu_static_custom_uefi_checksum: 'sha256:ab9c3db54d41f566a968285b8c6bc646bc8ff0183e0863f289bd8befbd93d05a'
Verify the checksums of the ISO (`lisoq_iso_file_url`, `_local` or `_remote`), the static QEMU archive
(`lisoq_qemu_static_custom_url` or `_local`) and the UEFI archive. Off by default; with `lisoq_checksum_enable: true`
the role fails on a mismatch, and also when a checksum for a file it uses is empty.
The format is `<algorithm>:<hex digest>` (`md5`, `sha1`, `sha224`, `sha256`, `sha384`, `sha512`); for files downloaded
from a URL also `<algorithm>:<URL of a checksum file>` in the `sha256sum` format (as `get_url` accepts).
The defaults are the checksums of the default files: the ISO one is published by mfsbsd, the archives from
support.org.ua have no published checksums (the files on the mirrors may differ). If you change a file,
set its checksum too.
Downloads and uploads are verified on the target before they are used; with checksums, the archives are downloaded
to the work directory first and extracted from there (again only when the archive changes).

    lisoq_ramdisk_enable: false
Use (and create) RAM-disk partitions on the target system (before running QEMU).

    lisoq_ramdisk_path: '/mnt'
The preferred path for the RAM-disk partition. The role keeps its files (ISO, QEMU archives) in the `lisoq` subdirectory of the chosen path
(mode 0700, owned by the user the role runs as, or by the SSH login user when local files are uploaded: they are
uploaded without become; a directory owned by either of them is reused). A missing directory is created with mode 0755;
the mode of an existing one is not changed.

    lisoq_ramdisk_another_path: '/tmp'
The alternative path for the RAM-disk partition, used when `lisoq_ramdisk_path` is already mounted with another filesystem
or has a filesystem mounted below it (e.g. a server disk mounted on `/mnt` or `/mnt/data` in rescue mode; a tmpfs on top
would hide it).
If the chosen path is already a tmpfs, it is reused and grown to `used + lisoq_ramdisk_size`; it is never shrunk.
If neither path is usable, the role fails.

    lisoq_ramdisk_size: '250'
The size of the RAM-disk partition in MiB (mebibytes).

    lisoq_total_need_ram: '' # (lisoq_ramdisk_size + lisoq_qemu_ram) or min 300MiB - autodetect
The minimum amount of RAM on the target system in MiB (mebibytes). If empty, it is the sum of `lisoq_ramdisk_size` and `lisoq_qemu_ram` (at least 300 MiB).
In any case the role requires at least 512 MiB of RAM on the target system and 256 MiB of free RAM for QEMU.

    lisoq_ramdisk_package_enable: false
Create a RAM disk to store packages on the system in directory `/var/cache/yum` or `/var/cache/apt`. Not all LiveCD systems have extra 200-400 MB to store the package base, that's why we use RAM-disk.

    lisoq_ramdisk_package_size: '' # in MiB (mebibyte) - autodetect
The amount of MB of RAM that we can allocate for the correct installation of packages on the system. Empirically, it was found that you need a minimum of 300 MB. Afterwards, we can clean up this directory.

    lisoq_ramdisk_package_purge: false
After installing packages, unmount the package cache ramdisk to free its RAM. The package cache directory is left empty; installing packages later (or re-running the role) still works.

    lisoq_firewall_acl_enable: true
Allow the QEMU forwarded ports (`lisoq_qemu_args_port_ssh`, `lisoq_qemu_args_port_rdp`, `lisoq_qemu_args_port_vnc`)
only from the whitelisted IPs/networks; connections from other addresses to these ports are dropped (iptables).
Whitelists are separate for IPv4 and IPv6. The rules apply only to these ports, not to the server's own SSH.
Connections from the server itself (loopback, e.g. an SSH tunnel to the VNC port with `lisoq_qemu_vnc_type: local`)
are always allowed, also when the whitelists do not contain `127.0.0.0/8`.
Enabled by default since 1.4.0: without it anyone could reach the VM's SSH, and live ISOs such as mfsbsd
have a well-known root password.
The rules live in the `LISOQ_QEMU` chain (INPUT jumps to it). While a QEMU started by the role is still running,
its ports stay protected too, even if the port settings have changed. If IPv6 is enabled but `ip6tables` does not
work, the role fails instead of leaving the ports open over IPv6.
Setting it to `false` removes the `LISOQ_QEMU` chain left by an earlier run.
If firewalld is running, it is left on, and the QEMU ports are opened in its runtime configuration (default zone),
because with its nftables backend (EL8+) it would otherwise reject the whitelisted clients too. `firewall-cmd --reload`
closes them again until the role is re-run. Other nftables rulesets that drop these ports must allow them themselves.

    lisoq_firewall_acl_allow_ansible_ip: true
Also allow the address the Ansible control node connects from, as seen by the server
(the client IP from `SSH_CONNECTION`). If it cannot be detected (e.g. a local connection), only the
whitelists below are used and a message is printed.
QEMU forwards the SSH and RDP ports over IPv4 only (its user networking takes no IPv6 address for them), so if
Ansible connects over IPv6, add the IPv4 address you will connect from to `lisoq_firewall_acl_ipv4_white`
(the role prints a message in this case).

    lisoq_firewall_acl_ipv4_white:
      - '127.0.0.0/8'
Default white list for IPv4 networks (a string such as `'10.0.0.0/8,192.168.1.0/24'` works too; empty: none).

    lisoq_firewall_acl_ipv6_white:
      - '::1/128'
Default white list for IPv6 networks (a string works too; empty: none).

    lisoq_qemu_args: '
    -net nic
    -rtc base=localtime
    -M pc
    -vga std
    -daemonize
    '
List of required command line arguments to run QEMU. `-daemonize` is added if it is missing (without it QEMU
would stay in the foreground and the role would never finish).

## Workflow

1) Install the role

```
shell> ansible-galaxy role install click0.linux_run_iso_in_qemu
```

2) Look variables, e.g. in [`defaults/main.yml`](defaults/main.yml)

You can override them in the playbook and inventory.

## Example Playbooks

### Example #1

    - hosts: rescue_servers
      vars_files:
        - vars/main.yml
      roles:
        - click0.linux_run_iso_in_qemu
*Inside `vars/main.yml`*:

    lisoq_qemu_enable: true
    lisoq_qemu_static_custom_enable: true
    lisoq_iso_file_url: 'https://mfsbsd.vx.sk/files/iso/14/amd64/mfsbsd-14.2-RELEASE-amd64.iso'
    lisoq_qemu_vnc_type: 'share'
    lisoq_qemu_boot_once_cd: false
    lisoq_qemu_ram: '650'
    lisoq_ramdisk_package_enable: false
    lisoq_ramdisk_package_purge: false
    lisoq_firewall_acl_ipv4_white:
      - '127.0.0.0/8'
      - '10.0.0.0/8'
      - '192.168.0.0/16'
    lisoq_firewall_acl_ipv6_white: []
    lisoq_firewall_acl_enable: true

### Example #2

    - hosts: rescue_servers
      vars_files:
        - vars/main.yml
      roles:
        - click0.linux_run_iso_in_qemu
*Inside `vars/main.yml`*:

    lisoq_qemu_enable: true
    lisoq_qemu_install: true
    lisoq_qemu_ram: '1000'
    lisoq_qemu_cpu: '2'
    lisoq_iso_file_local: '../../files/ISO images/WinPE10_8_Strelec_2022.01.04.iso'
    lisoq_qemu_vnc_type: 'share'
    lisoq_ramdisk_enable: true
    lisoq_ramdisk_size: '4100'
    lisoq_firewall_acl_ipv4_white:
      - '127.0.0.0/8'
      - '10.0.0.0/8'
      - '192.168.0.0/16'
    lisoq_firewall_acl_enable: true

## TODO

- [ ] Test on a Linux LiveCD based:
    - Debian 
    - Rocky Linux
    - Alpine
    - ArchLinux
    - OpenWRT
- [ ] Set up Internet access inside QEMU

## Tested

- [x] Freshly installed on HDD a Debian "bullseye" 11
- [x] On running from LiveCD Centos 7

## Dependencies

None.

## Further use

### License

BSD 3-Clause

### Author:

- Vladislav V. Prodan `<github.com/click0>`

### 🤝 Contributing

Contributions, issues and feature requests are welcome!<br>
Feel free to check [issues page](https://github.com/click0/ansible-linux-run-iso-in-qemu/issues).

### Show your support

Give a ⭐ if this project helped you!

<a href="https://www.buymeacoffee.com/click0" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
