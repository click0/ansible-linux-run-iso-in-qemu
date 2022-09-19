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
The ISO can be used as your favorite OS install disk, diagnostic disk, or other live operating system ([Live-CD](https://en.wikipedia.org/wiki/Live_CD))
Sources for obtaining ISO and QEMU universal binary - local system running Ansible, Rescue server mode itself and ftp/http(s).

There is no Internet inside the system running inside QEMU yet, but we will fix this in the next release.  
To increase security for access to the system in QEMU, you can specify a whitelist of IP/networks through the `iptables` firewall.  

## Requirements

Linux system Debian or CentOS.  
Installed packages:
  - python3
  - python3-apt

## Variables

See the `defaults/main.yml` and examples in vars:

    lisoq_qemu_enable: false
Do I need to use and run QEMU. Without this option, the role can download the ISO image and configure the firewall.

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
Auxiliary UEFI BIOS archive URL to support block devices larger than 2 TiB.

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

    lisoq_qemu_exclude_disk:
    - 'fd0'
    - 'sr0'

List of block disk devices to be excluded from the `lisoq_qemu_disk` list. The exclusion list usually contains FDD and CD-ROM devices.

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

    lisoq_iso_file_url: 'https://mfsbsd.vx.sk/files/iso/12/amd64/mfsbsd-12.2-RELEASE-amd64.iso'
URL location with ISO image file.

    lisoq_iso_file_ssh_port: '22' 
Sshd port that accepts connections _inside_ ISO image.

    lisoq_ramdisk_enable: false
Use (and create) RAM-disk partitions on the target system (before running QEMU).

    lisoq_ramdisk_location: '/mnt'
The preferred path for the RAM-disk partition.

    lisoq_ramdisk_another_location: '/tmp'
The alternative path for a RAM-disk partition if it is already in use internally. Subsequently, we will expand it to the desired size.

    lisoq_ramdisk_existed: false
Detect flag if RAM-disk partition is already in use. Service (local) variable.

    lisoq_ramdisk_mounted: false
Detect flag if RAM-disk partition is already in mounted. Service (local) variable.

    lisoq_ramdisk_size: '300'
The size of the RAM-disk partition in MiB (mebibytes).

    lisoq_total_need_ram: "( {{ lisoq_ramdisk_size | int + lisoq_qemu_ram | int }} | default('300') )" 
The minimum amount of RAM on the target system in MiB (mebibytes). The sum of two components - `lisoq_ramdisk_size` and `lisoq_qemu_ram`.

    lisoq_firewall_acl_enable: false 
Allow ACLs to whitelist IP's/net's and some listening ports (for example, `{{ lisoq_qemu_args_port_ssh }}` and `{{ lisoq_qemu_args_port_vnc }}`). Connections from other IPs to these ports are dropped. Whitelists are separate for IPv4 and IPv6 networks.

    lisoq_firewall_acl_ipv4_white:
      - '127.0.0.0/8'
Default white list for IPv4 networks.

    lisoq_firewall_acl_ipv6_white:
      - '::1/128'
Default white list for IPv6 networks.

    lisoq_firewall_acl_ports:
      - '{{ lisoq_qemu_args_port_ssh | default(omit) }}'
      - '{{ lisoq_qemu_args_port_rdp | default(omit) }}'
      - '{{ lisoq_qemu_args_port_vnc | default(omit) }}'
Default port ACL for a firewall.

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

2) Look variables, e.g. in `defaults/main.yml`

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
    lisoq_iso_file_url: 'https://mfsbsd.vx.sk/files/iso/12/amd64/mfsbsd-12.2-RELEASE-amd64.iso'
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
    - CentOS
    - Rocky Linux
    - Alpine
    - ArchLinux
    - OpenWRT
- [ ] Set up Internet access inside QEMU

## Tested

- [x] Freshly installed on HDD a Debian "bullseye" 11

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
