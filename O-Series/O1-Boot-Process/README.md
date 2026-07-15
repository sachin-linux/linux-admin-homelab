# O1 - Boot Process

## What This Module Covers

The Boot Process is the sequence of events that takes a Linux system from power-on to a usable login prompt. It spans firmware (BIOS/UEFI), the bootloader (GRUB2), the Linux kernel, the initial RAM filesystem (initramfs), and the init system (systemd) - each stage handing off control to the next.

---

## Why This Matters

- **Troubleshooting** - Every boot failure (broken GRUB entry, initramfs can't find root, silent hang) traces back to one specific stage - knowing the stages tells you exactly where to look
- **Distro building** - Package building, ISO creation, and kernel work (O2-O4) all assume this foundation is solid - CIPHER Linux's install and update process depends on getting this right
- **Recovery skills** - Knowing boot stages is what seperates "can install Linux" from "can actually fix Linux" when a system won't start
- **Interview relevance** - GRUB recovery, initramfs failures, and systemd targets are standard Linux Admin/SysAdmin interview topics

---

## Key Concept

| Term | Meaning |
|------|---------|
|BIOS | Legacy firmware - runs POST, reads the MBR (first 512 bytes of boot disk) for boot code |
|UEFI | Modern frrmware - supports GPT/larger disks and Secure Boot (verifies bootloader befrore running it) |
|GRUB2 | Bootloader - loads the kernel + initramfs into memory and hands off control |
|grub.cfg | Auto-generated GRUB config at /boot/grub/grub.cfg never hand-edited directly |
|/etc/default/grub | The actual editable source for GRUB settings - changes applied via update-grub |
|initramfs | Temporary in-RAM filesystem with just enough drives/tools to locate and mount the real root filesystem, then switch_root into it |
|vmlinuz | The complied Linux kernel binary, stored in /boot |
|root=UUID | Kernel boot parameter telling it where real root lives - UUID used instead of device name since device names can shift between boots |
|systemd | PID 1 parent of every process, brings the system up through targets |
|multi-user.target | Full non-graphical system (services + networking, no GUI) - typical for servers |
|graphical.target | multi-user.target + display manager/GUI - typical for desktops | 
|grub rescue> | Prompt shown when GRUB itself is broken - kernel and initramfs never even loaded |
|(initramfs) shell | Prompt shown when GRUB and kernel succeeded but initramfs couldn't find/mount real root |

---

## Core Commands

```bash
# Firmware type
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS (Legacy)"   # Check BIOS vs UEFI

# GRUB
sudo cat /boot/grub/grub.cfg	#view generated config (read-only, never hand-edit)
cat /etc/default/grub	#view editable source of GRUB settings
sudo update-grub	#Regenerate grub.cfg after editing /etc/default/grub

# Kernel and initramfs
ls -lh /boot/	#List installed kernels + matching initrd images
sudo update-initramfs -u	#Rebuild initramfs for the current kernel

# systemd targets
systemctl get-default	#show current default boot target

# Recovery
blkid	#Show actual current UUIDs of all block devices
```


## Scenarios Practiced

### Scenario 1 - Firmware Type Check
**Problem:** Need to confirm whether the kali VM boots via BIOS or UEFI before inspecting GRUB.	
**Investigate:** Ran `[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS` - result was BIOS (Legacy), meaning the VM's virtual firmware emulates classic BIOS, not UEFI.
**Fix:** No fix needed - observation exercise.
**Key lesson:** Boot stage logic (GRUB -> Kernel -> initramfs -> systemd) is identical either way - only Stage 1's disk-lookup mechanism (MBR vs GPT) differs between BIOS and UEFI.

### Scenario 2 - Installed kernels and initramfs Pairing
**Problem:** Need to confirm which kernels and initramfs images actually exist on disk, and whether GRUB's menu entries match real files.
**Investigate:** Ran `ls -lh /boot/` - found three complete kernel sets (6.18.12, 6.19.14, 7.0.12+kali-amd64), each with its own matching vmlinuz, initrd.img, config, and System.map.
**Fix:** No fix needed - observation exercise.
**Key lesson:** Kernel updates don't delete old kernels, they add new ones alongside - this is why GRUB's menu has multiple/advanced entries as a safety net. initramfs is always build and paired per-kernel-version, never shared or mixed.

### Scenario 3 - Tracing a Real GRUB menuentry Block
**Problem:** Need to connect GRUB's actual config to the theory - which line loads the kernel, which loads initramfs, and how root is identified.
**Investigate:** Ran `sudo grep -A 15 "menuentry'...7.0.12..." /boot/grub/grub.cfg` - found the `linux` line pointing to `/boot/vmlinuz-7.0.12+kali-amd64` with `root=UUID=3f4ae088-...``ro quiet splash`, and the `initrd` line pointing to `/boot/initrd.img-7.0.12+kali-amd64`.
**Fix:** No fix needed - observation exercise.
**Key lesson:** The `linux` line loads the kernel and passes it a UUID to look for, but the kernel can't act on that  alone - it's initramfs's job to actually find, driver-up, and mount that UUID, then switch_root into it. Kernel and initramfs versions in a menuentry always match exactly.

### Scenario 4 - Systemd Default Target Check
**Problem:** Need to confirm what target this VM boots into by default. 
**Investigate:** Ran `systemctl get-default` - result was `graphical.target`, expected for a desktop Kali install.
**Fix:** No fix needed - observation exercise.
**Key lesson:** A server edition of CIPHER Linux would default to `multi-user.target` instead, skipping the display manager entirely.

### Scenario 5 - Capstone: Diagnosing a UUID Mismatch After Disk Clone
**Problem:** A VM disk gets cloned and the clone receives a new UUID, but grub.cfg still references the old one - need to detemine exactly where boot fails, not just guess "it won't boot".
**Investigate step by step:**
```bash
# Traced the sequence stage by stage instead of assuming an early failure:
# 1. GRUB doesn't validate root UUID at all — it only loads files
# 2. Kernel itself boots fine and hands off to initramfs
# 3. initramfs is the stage that actually searches for the UUID
```

**Fix:**
```bash 
blkid	# find the real current UUID from the (initramfs) rescue shell
# Then either:
# - manually correct the root= parameter at the GRUB menu (press e to edit), or
# - boot a live USB, chroot in, and run:
sudo update-initramfs -u
sudo update-grub
```

## Golden Rules 
- **Never hand-edit grub.cfg** - always edit /etc/default/grub or /etc/grub.d/, then run update-grub
- **Kernel and initramfs versions must always match** - never mix vmlinuz-X with initrd.img-Y
- **grub rescue> means read GRUB itself is broken** (Stage 2) - kernel and initramfs never got a chance to load
- **(initramfs) shell means real root couldn't be mounted** (Stage 4) - check blkid first
- **CIPHER Linux ISOs must be hybrid BIOS+UEFI bootloader** - end-user hardware is unknown


## Skills Gained
- Diagnosing exactly which boot stage a failure belongs to, instead of guessing
- Reading and interpreting a real GRUB menuentry block line by line
- Understanding the purpose-built relationship between kernel and initramfs versions
- Practical recovery path for a UUID-mismatch boot failure after a disk clone
- Distinguishing a GRUB-level failure from an initramfs-level failure by their exact symptoms


## Environment Used 
| Component | Detail |
|-----------|--------|
|Host Machine | Kali Linux VM (VirtualBox) |
|Firmware | BIOS (Legacy) |
|Init system | systemd (graphical.target default) |
|Bootloader | GRUB2, Kernel 7.0.12+kali-amd64 (latest of 3 installed kernel sets) |
|Remote Repo | github.com/sachin-linux/linux-admin-homelab |
|Key Tools | grub, update-grub, update-initramfs, systemctl, blkid | 
