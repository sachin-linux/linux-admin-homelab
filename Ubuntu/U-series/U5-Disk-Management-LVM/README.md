# U5 - Disk Management (LVM)

## Objective 
Manage Linux storage using partitions, filesystem, and Logical Volume Manager (LVM).

---


## Topics Covered

- Disk identification
- Disk partitioning
- Filesystem creation
- Mounting filesystems
- Persistent mounts
- LVM architecture
- Logical volume expansion
- LVM snapshots

---


## Key Commands
| Command | Purpose |
|---------|---------|
| `lsblk` | List block devices |
| `fdisk` | Partition management |
| `mkfs.ext4` | Create ext4 filesystem |
| `mount` | Mount filesystem |
| `umount` | Unmount filesystem |
| `df -h` | Show disk usage |
| `pvs` | List physical volumes |
| `vgs` | List volume groups |
| `lvs` | List logical volumes |

---

## Disk Identification
```bash
lsblk			# List all disks and partitions
sudo fdisk -l		# Show detailed disk information	
```

---


## Filesystem Creation
```bash
Sudo mkfs.ext4 /dev/sdb1
```

---


## Mount Filesystem
```bash
sudo mount /dev/sdb1 /mnt
```

---


## Persistent Mounts
Edit `/etc/fstab` to mount automatically at boot:
```
/dev/sdb1 /data ext4 defaults 0 2
```

---


## LVM Architecture

###Physical Volume (PV)
```bash
pvcreate /dev/sdb1
```

###Volume Group (VG)
```bash
vgcreate vgdata /dev/sdb1
```

###Logical Volume (LV)
```bash
lvcreate -L 5G -n lvdata vgdata
```

## Expand Logical Volume 
```bash
lvextend -L +2G /dev/vgdata/lvdata
resize2fs /dev/vgdata/lvdata
```

## LVM Snapshot
```bash
lvcreate -L 2G -s -n snapshot /dev/vgdata/lvdata
```

---


## Lab 

1. Create disk partition
2. Create physical volume
3. Create volume group
4. Create logical volume 
5. Mount logical volume
6. Extend storage
7. Create snapshot

## Skills Gained

- Storage administration
- Logical volume management 
- Dynamic storage expannsion

---

## Environments Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
