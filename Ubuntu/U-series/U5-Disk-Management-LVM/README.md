# U5 - Disk Management (LVM)

## Objective 
Manage Linux storage using partitions, filesystem, and Logical Volume Manager (LVM)

## Topics Covered

- Disk identification'
- Disk partitioning
- Filesystem creation
- Mounting filesystems
- Persistent mounts
- LVM architecture
- Logical volume expansion
- LVM snapshots

## Key Commands

lsblk
fdisk 
mkfs.ext4
mount
unmount
df -h
pvs
vgs
lvs

## Disk Identification

lsblk

Show disk information

sudo fdisk -l

## Filesystem Creation

Sudo mkfs.ext4 /dev/sdb1

## Mount Filesystem

sudo mount /dev/sdb1 /mnt

## Persistent Mounts

/etc/fstab

Example entry

/dev/sdb1 /data ext4 defaults 0 2

## LVM Architecture

Physical Volume (PV)

pvcreate /dev/sdb1

Volume Group (VG)

vgcreate vgdata /dev/sdb1

Logical Volume (LV)

lvcreate -L 5G -n lvdata vgdata

## Expand Logical Volume 

lvextend -L +2G /dev/vgdata/lvdata

resize filesystems

resize2fs /dev/vgdata/lvdata

## LVM Snapshot

lvcreate -L 2G -s -n snapshot /dev/vgdata/lvdata

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

Ubuntu Linux
VirtualBox
Linux CLI tools

