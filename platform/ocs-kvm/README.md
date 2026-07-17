# SONIC ocs-kvm Platform Build and Run Instructions

This doc contains the procedure to compile, run and test the SONiC-OCS KVM image, the prototype the team currently has.  
For SONiC compilation environment setup, please refer to [sonic-buildimage](https://github.com/sonic-net/sonic-buildimage) and [README.md](https://github.com/sonic-net/sonic-buildimage/blob/master/README.md)

# Prebuilt image
A prebuilt image is published as a GitHub release, so you can skip the build steps
below and download it directly:

- [sonic-ocs-kvm.img.gz](https://github.com/sonic-ocs/sonic-buildimage/releases/download/ocs-kvm-v1.0/sonic-ocs-kvm.img.gz) (release [`ocs-kvm-v1.0`](https://github.com/sonic-ocs/sonic-buildimage/releases/tag/ocs-kvm-v1.0))

# HOWTO Build ocs-kvm image

``` bash
make init
make configure PLATFORM=ocs-kvm
make BLDENV=trixie SONIC_BUILD_JOBS=8 target/sonic-ocs-kvm.img.gz
```

# HOWTO setup KVM environment
1. Install Ubuntu KVM tools

```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y 
```

2. Check CPU virtualization support

```bash
kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```

3. Copy the SONiC image to host
    - sonic-ocs-kvm.img.gz      --- compressed SONiC image 

4. Decompress the image
```bash
gunzip sonic-ocs-kvm.img.gz
```

## Running SONiC OCS KVM
Boot the image with the serial console attached to your terminal (`-nographic`).
All interaction with the VM is done over this console; no ethernet/SSH access is
required.
```bash
sudo qemu-system-x86_64 \
  -hda sonic-ocs-kvm.img \
  -enable-kvm -m 4096 -smp 4 \
  -nographic


                             GNU GRUB  version 2.02

 +----------------------------------------------------------------------------+
 |*SONiC-OS-ocs-dev.0-4e2af959f                                              | 
 | ONIE                                                                       |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            | 
 +----------------------------------------------------------------------------+

      Use the ^ and v keys to select which entry is highlighted.
      Press enter to boot the selected OS, `e' to edit the commands       
      before booting or `c' for a command-line.

                             GNU GRUB  version 2.02
```
If want to quit qemu, please hold Ctrl and press A, then release both keys, and press X.

# HOWTO use ocs-kvm image
## Login via serial console
Once the VM finishes booting, the login prompt appears directly on the serial
console (the same terminal where `qemu-system-x86_64 -nographic` is running).
Input user and password to login, which are configured in config file, admin/YourPaSsWoRd for default.
```
sonic login: admin
Password: 
Linux sonic 6.12.41+deb13-sonic-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.41-1 (2026-07-20) x86_64
You are on
  ____   ___  _   _ _  ____
 / ___| / _ \| \ | (_)/ ___|
 \___ \| | | |  \| | | |
  ___) | |_| | |\  | | |___
 |____/ \___/|_| \_|_|\____|

-- Software for Open Networking in the Cloud --

Unauthorized access and/or use are prohibited.
All access and/or use are subject to monitoring.

Help:    https://sonic-net.github.io/SONiC/

Last login: Tue Jul 21 02:20:22 UTC 2026 on ttyS0
admin@sonic:~$
```

## Show software version
```bash
admin@sonic:~$ show version

SONiC Software Version: SONiC.ocs-dev.0-4e2af959f
SONiC OS Version: 13
Distribution: Debian 13.6
Kernel: 6.12.41+deb13-sonic-amd64
Build commit: 4e2af959f
Build date: Mon Jul 20 23:16:58 UTC 2026
Built by: jimmy@SONIC-003

Platform: x86_64-ocs-kvm_x86_64-r0
HwSKU: OCS-V
ASIC: ocs-kvm
ASIC Count: 1
Serial Number: 123456789
Model Number: OCS-KVM
Hardware Revision: 1.0
Uptime: 02:20:22 up 2 min,  1 user,  load average: 3.75, 1.78, 0.68
admin@sonic:~$
```

## Show PMON platform information
> Note: On KVM the platform monitoring stack (`pmon`) comes up a while after the
> login prompt appears. Allow ~3 minutes after power-on before running
> `show platform` — until `pmon` is fully up the PSU / fan / temperature /
> firmware tables are empty or incomplete.

### Show summary information
```bash
admin@sonic:~$ show platform summary 
Platform: x86_64-ocs-kvm_x86_64-r0
HwSKU: OCS-V
ASIC: ocs-kvm
ASIC Count: 1
Serial Number: 123456789
Model Number: OCS-KVM
Hardware Revision: 1.0
admin@sonic:~$
```

### Show PSU information
```bash
admin@sonic:~$ show platform psu
PSU    Model         Serial    HW Rev    Voltage (V)    Current (A)    Power (W)  Status    LED
-----  ---------  ---------  --------  -------------  -------------  -----------  --------  -----
PSU0   PSU Model  123456789      1.00          12.00           1.50        18.00  OK        green
PSU1   PSU Model  123456789      1.00          12.00           1.50        18.00  OK        green
admin@sonic:~$ 
```

### Show fan information
```bash
admin@sonic:~$ show platform fan
  Drawer    LED            FAN    Speed    Direction    Presence    Status          Timestamp
--------  -----  -------------  -------  -----------  ----------  --------  -----------------
FanTray0  green  FanTray0-Fan0      50%       intake     Present        OK  20260721 02:20:10
FanTray0  green  FanTray0-Fan1      50%       intake     Present        OK  20260721 02:20:10
FanTray0  green  FanTray0-Fan2      50%       intake     Present        OK  20260721 02:20:10
FanTray0  green  FanTray0-Fan3      50%       intake     Present        OK  20260721 02:20:10
     N/A  green       PSU0-Fan      50%       intake     Present        OK  20260721 02:20:10
     N/A  green       PSU1-Fan      50%       intake     Present        OK  20260721 02:20:10
admin@sonic:~$
```

### Show thermal information
```bash
admin@sonic:~$ show platform temperature 
        Sensor    Temperature    High TH    Low TH    Crit High TH    Crit Low TH    Warning          Timestamp
--------------  -------------  ---------  --------  --------------  -------------  ---------  -----------------
  System Board             35         70        10              90              5      False  20260721 02:20:10
System Exhaust             35         70        10              90              5      False  20260721 02:20:10
admin@sonic:~$
```

### Show firmware information
```bash
admin@sonic:~$ show platform firmware status
Chassis    Module       Component      Version  Description
---------  -----------  -----------  ---------  -------------------------------------------------------------
OCS        LINE-CARD0   OCS0-0               1  Optical Circuit Switch of 16x16
           SUPERVISOR0  BIOS                 1  Performs initialization of hardware components during booting
                        FPGA                 1  Platform managment controller for on-board components
                        CPLD                 1  Used for managing IO modules
                        ONIE                 1  Open network install environment
admin@sonic:~$
```

## Redis
We have added the following tables to support data of OCS.
- For CONFIG_DB (DB 4)
  - OCS_PORT
  - OCS_CROSS_CONNECT
- For STATE_DB (DB 6)
  - OCS_PORT_TABLE
  - OCS_CROSS_CONNECT_TABLE

### Populate the CONFIG_DB OCS tables
A sample OCS configuration (16 ingress ports `1A..16A`, 16 egress ports `1B..16B`,
and 16 cross-connects) ships with the OCS-V HwSKU as `ocs_config.json` under the
device directory (`/usr/share/sonic/device/<platform>/OCS-V/ocs_config.json`).
Load it into CONFIG_DB with:
```bash
admin@sonic:~$ sudo sonic-cfggen -j $(find /usr/share/sonic -name ocs_config.json | head -1) --write-to-db
```

Verify the CONFIG_DB tables:
```bash
admin@sonic:~$ sudo sonic-db-cli CONFIG_DB keys 'OCS_PORT|*' | wc -l
32
admin@sonic:~$ sudo sonic-db-cli CONFIG_DB keys 'OCS_PORT|*' | sort -V | head -4
OCS_PORT|1A
OCS_PORT|1B
OCS_PORT|2A
OCS_PORT|2B
admin@sonic:~$ sudo sonic-db-cli CONFIG_DB hgetall 'OCS_PORT|1A'
{'config_status': 'normal', 'label': 'ingress_port1'}

admin@sonic:~$ sudo sonic-db-cli CONFIG_DB keys 'OCS_CROSS_CONNECT|*' | wc -l
16
admin@sonic:~$ sudo sonic-db-cli CONFIG_DB hgetall 'OCS_CROSS_CONNECT|1A-16B'
{'a_side': '1A', 'b_side': '16B'}
```

> Note: The STATE_DB tables (`OCS_PORT_TABLE`, `OCS_CROSS_CONNECT_TABLE`) are
> populated at runtime by `syncd` from COUNTERS_DB via the
> `ocs_port_attrs.lua` / `ocs_cross_connect_attrs.lua` flex-counter scripts.
> On this virtual platform they remain empty until the OCS objects are
> programmed through SAI, so `sudo sonic-db-cli STATE_DB keys 'OCS_PORT_TABLE|*'`
> returns nothing after only loading CONFIG_DB.
