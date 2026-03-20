# U6 - Backup Concepts

## Objective 
Protect production systems from data loss and ensure data can be restored when needed.
Backups are one of the most critical responsibilities of a Linux administrator.

---

# Topics Covered
- Backup types (Full, Incremental, Differential)
- Linux backup tools (rsync, tar, cp, scp)
- Backup storage locations
- Restore testing

---

## Backup Types

| Type | Description | Advantage | Disadvantage |
|------|-------------|-----------|--------------|
| Full | Copies all files and data | Complete copy, easy restore | Slow, requires more storage |
| Incremental | Backs up changes since last backup | Fast, less storage | Restore requires full + all incrementals |
| Differential | Backs up changes since last full backup | Faster restore than incremental | Backup size grows each day |

### Full Backup Strategy
```
day 1 -> Full Backup
```
 
### Incremental Backup Strategy
```
Day 1 -> Full Backup
Day 2 -> Incremental Backup
Day 3 -> Incremental Backup 
```

### Differentail Backup Strategy
```
Day 1 -> Full Backup
Day 2 -> Differential Backup
Day 3 -> Differential Backup
```

---


# Linux Backup Tools

### rsync - most widely used
```bash
rsync -av source/ destination/
```
| Option | Meaning |
|--------|---------|
| `-a` | Archive mode (preserves permissions, timestamps) |
| `-v` | Verbose output |


### tar - compressed archives
```bash
tar -czvf backup.tar.gz folder/
```
| Option | Meaning |
|--------|---------|
| `-c` | Create archive |
| `-z` | gzip compression |
| `-v` | Verbose |
| `-f` | Filename |
 

### cp - basic file copy
```bash
cp file1 backup-location/
```
Useful for simple backups.


### scp - secure remote copy over SSH
```bash
scp backup.tar.gz user@remote-server:/backup/
```

---

# Backup Locations
| Location | Description | Risk |
|----------|-------------|------|
| Local Disk | Stored on same machine (`/backup`) | Hardware failure |
| External Storage | External HDD or NAS | Low |
| Remote Server | Another machine via rsync/scp | Low |


---

## Lab 1 - Basic Backup Using rsync
```bash
mkdir ~/backup-lab && cd ~/backup-lab
touch file1 file2 file3
mkdir ~/backup-storage 
rsync -av ~/backup-lab/ ~/backup-storage/
ls ~/backup-storage
```

---

## Lab 2 - Simulate File Loss and Restore
```bash
rm ~/backup-lab/file1
cp ~/backup-storage/file1 ~/backup-lab/
ls ~/backup-lab
```

---

## Lab 3 - Archive Backup with tar
```
tar -czvf backup.tar.gz ~/backup-lab
tar -tvf backup.tar.gz
tar -xzvf backup.tar.gz


---


## Skills Gained 

- Understanding backup strategies 
- Perform backups using rsync
- Create compressed backups using tar
- Restore lost files
- Verify backup integrity


---


## Environments Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
