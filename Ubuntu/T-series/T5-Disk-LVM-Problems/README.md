# T5 -Disk LVM Problems

## What This Module Covers
Real-world disk and LVM troubleshooting scenarios - diagnosing and fixing broken storage the way you would on the job. This module covers fstab misconfigurations causing emergency causing emergency mode, deactivated logical volumes and volume groups, full filesystems, and files recovery using LVM snapshots.

---

## Scenarios Completed

### Scenario 1 - Fake fstab Entry Causing Emergency Mode

- **Problem:** Systems dropped into emergency mode on boot - could not reach normal login
- **Diagnose:** `journalctl -xb -p err` -> `Timed out waiting for device dev-fake-device.device - /dev/fake/device`
- **Root cause:** A non-existent device `/dev/fake/device` was added to `/etc/fstab` - system timed out waiting for it on boot and panicked into emergency mode
- **Fix:** `sudo nano /etc/fstab` -> deleted the fake `/dev/fake/device` line -> rebooted
- **Verify:** System booted normally into login prompt

---

### Scenario 2 - dd Corruption on Physical Volume

- **Problem:** `dd if=/dev/urandom` wrote data to first 512 bytes of `/dev/sdb` (PV metadata area)
- **Diagnose:** `sudo fsck -n /dev/t5vg/t5lv` -> filesystem reported clean
- **Root cause:** LVM stores backup metadata that can survive partial corruption at the start of the disk - the VG and filesystem recovered automatically
- **Fix:** No fix needed - LVM metadata redundancy saved the data
- **Key lesson:** `dd` is destructive. Always double-check the target device before running. `dd if=/dev/urandom of =/dev/sda` on the wrong disk = unrecoverable data loss

---

### Scenario 3 - Deactivated Logical Volume (lvchange -an)

- **Problem:** `/mnt/t5data` appeared empty after reboot - data seemed gone
- **Diagnose:** `lsblk` -> no mountpoint shown for `t5vg-t5lv` | `sudo lvs -a` -> After showed `-wi-------` (missing `a` and `o` flags)
- **Root cause:** `lvchange -an` deactivated the LV - deactivated LVs do not appear in `lsblk` and cannot be mounted even if an fstab entry exists
- **Fix:** `sudo lvchange -ay t5vg/t5lv` -> `sudo mount /mnt/t5data`
- **Verify:** `lsblk` -> `/mnt/t5data` mountpoint restored

---

### Scenario 4 - Deactivated Entire Volume Group (vgchange -an)

- **Problem:** Both `/mnt/t5data` and `/mnt/t5backup` appeared empty - all LVs invisible in `lsblk`
- **Diagnose:** `lsblk` -> `sdb` showed no LVs underneath | `sudo lvs` -> Attr showed `-wi-------` for all LVs in `t5vg`
- **Root cause:** `vgchange -an` deactivates the entire volume group at once - all LVs inside become inactive and invisible to the system
- **Fix:** `sudo vgchange -ay t5vg` -> `sudo mount /dev/t5vg/t5lv2 /mnt/t5backup`
- **Verify:** `lsblk` -> both `/mnt/t5data` and `/mnt/t5backup` mountpoints restored

---

### Scenario 5 - Full Filesystem (No Space Left on Device) 

- **Problem:** Developer getting `No space left on device` writing to `/mnt/t5logs`
- **Diagnose:** `df -h` -> `/mnt/t5logs` at `100` | `sudo vgs` -> `t5vg` had `1.51G` free space available
- **Root cause:** LV was created too small - filesystem filled up but the volume group still had free space that could be used
- **Fix:** `sudo lvextend -L +500M --resizefs /dev/t5vg/t5lv3`
- **Verify:** `df -h` -> `/mnt/t5logs` dropped from `100%` to `52%`

---

### Scenario 6 - File Recovery Using LVM Snapshot

- **Problem:** Developer accidentally deleted `/mnt/t5data/importantfile.txt`
- **Diagnose:** `sudo lvs` -> found `t5lv_snap` with `s` in Attr column and `Origin = t5lv` - a snapshot existed from before the deletion
- **Fix:** 
  ```bash
  sudo mount -o ro /dev/t5vg/t5lv_snap /mnt/t5snap
  sudo cp /mnt/t5snap/importantfile.txt /mnt/t5data/
  ```
- **Verify:** `sudo diff /mnt/t5snap/importantfile.txt /mnt/t5data/importantfile.txt` -> no output = files identical
- **Root cause:** Snapshots capture the LV state at the time they are taken. Always snapshot **before** risky operations - snapshotting after deletion means the file is already gone

---

## Key Commands 

| Command | Purpose |
|---------|---------|
| `lsblk` | List block devices and mount points |
| `sudo pvs` | Show physical volumes |
| `sudo vgs` | Show volume groups and free space |
| `sudo lvs` | Show logical volumes and status |
| `sudo lvs -a` | Show all LVs including snapshots |
| `sudo pvcreate /dev/sdb` | Initialize disk as physical volume |
| `sudo vgcreate t5vg /dev/sdb` | Create a volume group |
| `sudo lvcreate -L 2G -n t5lv t5vg` | Create a 2G logical volume |
| `sudo mkfs.ext4 /dev/t5vg/t5lv` | Format LV with ext4 filesystem |
| `sudo mount /dev/t5vg/t5lv /mnt/t5data` | Mount a logical volume |
| `sudo lvchange -ay t5vg/t5lv` | Activate a specific LV |
| `sudo lvchange -an t5vg/t5lv` | Deactivate a specific LV |
| `sudo vgchange -ay t5vg` | Activate entire volume group |
| `sudo vgchange -an t5vg` | Deactivate entire volume group |
| `sudo lvextend -L +500M --resizefs /dev/t5vg/t5lv3` | Extend LV and resize filesystem online |
| `sudo fsck -n /dev/t5vg/t5lv` | Check filesystem integrity (dry run) |
| `df -h` | Show disk usage per filesystem |
| `sudo lvcreate -L 500M -s -n snap /dev/t5vg/t5lv` | Create LVM snapshot |
| `sudo mount -o ro /dev/t5vg/snap /mnt/snap` | Mount snapshot read-only |
| `sudo lvremove -f /dev/t5vg/snap` | Remove a snapshot |
| `sudo diff file1 file2` | Compare two files (no output = identical) |
| `sudo nano /etc/fstab` | Edit filesystem mount configuration |
| `journalctl -xb -p err` | Show boot errors only |

---

## log Locations

| Log / File | Purpose |
|-----------|---------|
| `journalctl -xb` | Full boot journal |
| `journalctl -xb -p err` | Boot errors only — fastest way to find what caused emergency mode |
| `/etc/fstab` | Filesystem mount config — checked on every boot |
| `dmesg | grep -i sdb` | Kernel messages about the disk |
| `dmesg | grep -i ext4` | Filesystem-related kernel messages |

---

## LVM Attr Flag Reference

| Flag | Meaning |
|------|---------|
| `a` | Active — LV is active and accessible |
| `o` | Open — LV is currently mounted and in use |
| `s` | Snapshot — this LV is a snapshot |
| `-wi-ao----` | Normal healthy mounted LV |
| `-wi-------` | LV exists but is inactive — not mountable |
| `swi-a-s---` | Active snapshot |

---

- Always run `lsblk` + `lvs` + `vgs` before touching any disk - know your layout first 
- ``dd`` is destructive - always double-check the target device before running
- Never add a fake or wrong device to `/etc/fstab` - it will cause emergency mode on next boot
- Use `vgchange -ay` to reactivate an entire VG - faster than activating LVs one by one
- `lvextend --resizefs` extends the LV and filesystem together online - no unmounting needed
- Always take LVM snapshots **before** risky operations - snapshotting after deletion is too late
- Mount snapshots with `-o ro` (read-only) during recovery - never write to a snapshot
- Verify file recovery with `diff` - no output means files are identical 
- `fsck -n` is safe - dry run only, makes no changes to the filesystem
- The `o` flag in `lvs` Attr means open/mounted - missing `o` means the LV is not in use

---

## Skills Gained 

- Reading and interpreting `lsblk`, `pvs`, `vgs`, `lvs` output to understand LVM layout
- Diagnosing emergency mode caused by bad fstab entries using `journalctl -xb -p err`
- Activating and deactivating individual LVs and entire volume groups
- Extending logical volumes and resizing filesystems online with `lvextend --resizefs`
- Creating LVM snapshots and using them for file recovery
- Verifying filesystem integrity with `fsck -n`
- Recovering deleted files from LVM from LVM snapshots and Verifying with `diff`

--- 

## Environment Used 

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Primary Disk | `/dev/sda` — 25G (OS disk) |
| Lab Disk | `/dev/sdb` — 5G (added via VirtualBox for this module) |
| Key Files | `/etc/fstab`, `/dev/t5vg/`, `/mnt/t5data`, `/mnt/t5backup`, `/mnt/t5logs` |
| Key Tools | `lsblk`, `pvs`, `vgs`, `lvs`, `lvcreate`, `lvextend`, `vgchange`, `fsck`, `mount`, `journalctl` |
