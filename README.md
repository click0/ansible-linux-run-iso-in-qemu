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

There is no Internet inside the system running inside QEMU yet, but we will fix this in the next release.  
To increase security for access to the system in QEMU, you can specify a whitelist of IP/networks through the `iptables` firewall.  

## Requirements

Linux system Debian or CentOS.  
Installed packages on target hosts:
  - python3
  - python3-apt
    
ansible-core 2.15 or newer on the control node (tested with 2.15 and 2.19).
For EL7 targets use ansible-core 2.15 or 2.16: newer versions do not support its Python.

Ansible collection on the control node:
  - `ansible.posix` >= 1.5.0 (`ansible-galaxy collection install ansible.posix`)

Installed packages on the control node (Ansible):
  - rsync
  - sshpass  
If you use password login to target hosts via `ssh`

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

    lisoq_qemu_static_custom_uefi_url: 'https://support.org.ua/Soft/vKVM/orig/uefi.tar.gz'
UEFI firmware archive (`uefi.bin`) used with `lisoq_qemu_uefi: true`.

    lisoq_qemu_uefi: false
Boot QEMU with UEFI firmware (`-bios uefi.bin`) instead of the default BIOS (SeaBIOS). Requires `lisoq_qemu_static_custom_enable: true`.
Enable it only if the OS must be installed or booted in UEFI mode, and only with an ISO that supports UEFI boot
(the default mfsbsd 14.2 ISO does, older mfsbsd 12.x ISOs do not). Disks larger than 2 TiB are fully usable in BIOS mode as well.

    lisoq_qemu_args_port_ssh: '1022'
External port for ssh forwarding to QEMU internal port `22`.

    lisoq_qemu_args_port_rdp: '3389'
External port for RDP forwarding to internal QEMU port `3389`

    lisoq_qemu_args_port_vnc: '5901'
External port for forwarding VNC to internal QEMU port `5901`

    lisoq_qemu_vnc_type: 'local'
The variable controls how QEMU will "listen" for VNC connections.
The value of the `local` variable is to listen only on `localhost`.
The value of the `share` variable is to listen on all IPs.

    lisoq_qemu_install: false
Install QEMU from the package repository.

    lisoq_qemu_ram: '1024'
How much RAM (in MiB) can you use inside QEMU.

    lisoq_qemu_cpu: '' 
How much CPU core can you use inside QEMU. By default `''` and role allocates all CPU cores for QEMU use.

    lisoq_qemu_disk: ''
List of block disk devices to connect to QEMU. By default, the role mounts all found block devices from the host machine.
You can specify your own list of block devices:

    lisoq_qemu_disk:
      - 'sda'
      - 'sdb'
<br>

    lisoq_qemu_disk_allow_in_use: false
Disks that are in use by the host (the disk, its partitions or LVM/md volumes on it are mounted or used as swap) are not passed to QEMU,
because writing to them from QEMU at the same time corrupts them. Autodetected disks in use are skipped with a message;
if such a disk is listed explicitly in `lisoq_qemu_disk`, the role fails. Set to `true` to pass them anyway (at your own risk).
On a rescue system booted into RAM, the server disks are not mounted, so all of them are passed as before.
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

    lisoq_ramdisk_enable: false
Use (and create) RAM-disk partitions on the target system (before running QEMU).

    lisoq_ramdisk_path: '/mnt'
The preferred path for the RAM-disk partition. The role keeps its files (ISO, QEMU archives) in the `lisoq` subdirectory of the chosen path.

    lisoq_ramdisk_another_path: '/tmp'
The alternative path for the RAM-disk partition, used when `lisoq_ramdisk_path` is already mounted with another filesystem
or has a filesystem mounted below it (e.g. a server disk mounted on `/mnt` or `/mnt/data` in rescue mode; a tmpfs on top
would hide it).
If the chosen path is already a tmpfs, it is reused and grown to `used + lisoq_ramdisk_size`; it is never shrunk.
If neither path is usable, the role fails.

    lisoq_ramdisk_size: '250'
The size of the RAM-disk partition in MiB (mebibytes).

    lisoq_total_need_ram: '' # (lisoq_ramdisk_size + lisoq_qemu_ram) or min 250MiB - autodetect 
The minimum amount of RAM on the target system in MiB (mebibytes). If empty, it is the sum of `lisoq_ramdisk_size` and `lisoq_qemu_ram` (at least 300 MiB).

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
Enabled by default since 1.4.0: without it anyone could reach the VM's SSH, and live ISOs such as mfsbsd
have a well-known root password.
The rules live in the `LISOQ_QEMU` chain (INPUT jumps to it). While a QEMU started by the role is still running,
its ports stay protected too, even if the port settings have changed. If IPv6 is enabled but `ip6tables` does not
work, the role fails instead of leaving the ports open over IPv6.
Setting it to `false` removes the `LISOQ_QEMU` chain left by an earlier run.

    lisoq_firewall_acl_allow_ansible_ip: true
Also allow the address the Ansible control node connects from, as seen by the server
(the client IP from `SSH_CONNECTION`). If it cannot be detected (e.g. a local connection), only the
whitelists below are used and a message is printed.

    lisoq_firewall_acl_ipv4_white:
      - '127.0.0.0/8'
Default white list for IPv4 networks.

    lisoq_firewall_acl_ipv6_white:
      - '::1/128'
Default white list for IPv6 networks.

    lisoq_qemu_args: '
    -net nic
    -rtc base=localtime
    -M pc
    -vga std
    -daemonize
    '
List of required command line arguments to run QEMU.

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
