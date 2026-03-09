# U6 - Backup Concepts

## Goal 
Protect production systems from data loss and ensure data can be restored when needed.

Backups are one of the most critical responsibilities of a Linux administrator.

---

# Backup Types

## Full Backup
A full backup copies **all files and data**.

Advantages:
- Complete copy
- Easy restore

Disadvantages:
- Takes more time
- Requires more storage

Example strategy:

Day 1 -> Full Backup

---

## Incremental Backup

Backs up **only the changes since the last backup**.

Example:

Day 1 -> Full Backup
Day 2 -> Incremental Backup
Day 3 -> Incremental Backup 

Advantages: 
- Faster
- Uses less storage

Disadvantages:
- Restore requires the **full backup + all incremental backups**

---

Differentail Backup

Backs up **changes since the last full backup**.

Example:

Day 1 -> Full Backup
Day 2 -> Differential Backup
Day 3 -> Differential Backup

Advantages:
- Faster restore than incremental

Disadvantages:
- Backup size increases each day

---

# Linux Backup Tools

## rsync

Most widely used Linux backup tool.

Features:
- Fast file synchronization
- Incremental transfer
- Works locally and remotely

Example:

rsync -av source/ destination/

Options:

-a -> archive mode
-v -> verbose output

---

## tar

Used to create **compressed archive backups**.

Create archive:

tar -czvf backup.tar.gz folder

Options:

-c -> create archive
-z -> gzip compression
-v -> verbose
-f -> filename 

---

## cp

Basic file copy command.

Example: 

cp file1 backup-location/

Useful for simple backups.

---

## scp

Secure copy between systems over SSH.

Example:

scp backup.tar.gz user@remote-server:/backup/

Used for remote backups.

---

# Backup Locations

## Local Disk

Backup stored on the same machine.

Example: 

/backup

Risk: hardware failure.

---

## External Storage

Examples:
- External hard drive
- NAS

Provides additional safety.

---

## Remote Server
Backup stored on another machine using tools like:

rsync
scp

Common in production environments.

---

# Restore Testing 

A backup is **useless if restore does not work**.

Administrators must:

- Verify backups
- Test restore procedures 
- Simulate data loss scenarios

---

# U6 Lab 1 - Basic Backup Using rsync

Create lab directory:

mkdir ~/backup-lab
cd ~/backup-lab

Create test files:

touch file1 file2 file3

Create backup storage:

mkdir ~/backup-storage 

Run backup:

rsync -av ~/backup-lab/ ~/backup-storage/

Verify backup: 

ls ~/backup-storage

---

# U6 Lab 2 - Simulate File Loss

Delete a file: 

rm ~/backup-lab/file1

Restore file from backup: 

cp ~/backup-storage/file1 ~/backup-lab/

Verify restoration:

ls ~/backup-lab

---

# U6 Lab 3 - Archive Backup with tar

Create compressed archive: 

tar -czvf backup.tar.gz ~/backup-lab

Verify archive contents:

tar -tvf backup.tar.gz

Restore archive:

tar -xzvf backup.tar.gz

---

Skills Gained 

- Understand backup 
- Perform backups using rsync
- Create compressed backups using tar
- Restore lost files
- Verify backup integrity

---

## Environments Used

Ubuntu Linux
VirtualBox
Linux CLI tools

