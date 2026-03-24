# T1 - User & Permission Issues

## what is User & Permission Management?

User and permission management is the practice of controlling who can access files, directories, and commands on a Linux system. Every file has an owner, a group, and a set of permissions that define what the owner, group members, and everyone else can do. As a Linux admin, you will regularly deal with broken permissions, locked accounts, and misconfigured sudo access - often under pressure when something is already broken in prodcution

---

## Why It Matters?

- **Security** - wrong permissions can expose sensitive files to unauthorised users
- **Access control** - users should only have access to what they need, nothing more
- **Real-world troubleshooting** - permissions issues are one of the most common problems reported by developers and users
- **interview relevance** - diagnosing and fixing permission problems is a standard junior Linux/DevOps interview topic

---

## Key Concepts

| Term | Meaning |
|---|---|
| Owner | The user who owns the file — set with `chown` |
| Group | The group assigned to the file — members share group permissions |
| Others | Everyone else on the system |
| r (read) | Value: 4 — read a file or list a directory |
| w (write) | Value: 2 — modify a file or create files in a directory |
| x (execute) | Value: 1 — run a file as a program, or enter a directory |
| chmod | Change file/directory permissions |
| chown | Change file owner and/or group |
| usermod -aG | Add a user to a group (always use -a to append, never -G alone) |
| passwd -l / -U | Lock or unlock a user account |
| passwd -S | Check account status — L = locked, P = active |
| visudo | Safe editor for /etc/sudoers — always use this, never edit directly |
| SUID | Set User ID — file runs as its owner regardless of who executes it |
| SGID | Set Group ID — file runs as its group; on directories, new files inherit the group |

---

## Permission Numeric Reference

| Value | Binary | Permissions |
|---|---|---|
| 7 | 111 | rwx |
| 6 | 110 | rw- |
| 5 | 101 | r-x |
| 4 | 100 | r-- |
| 0 | 000 | --- |

---

**Common permission sets:**

| Permission | Numeric | Typical Use |
|---|---|---|
| rw-r--r-- | 644 | Config files (e.g. /etc/passwd) |
| rwxr-xr-x | 755 | Directories and shared scripts |
| rwxr--r-- | 744 | Personal scripts |
| rw-rw-r-- | 664 | Shared log files |

> **Critical:** For Directories `x` means **enter** (not execute a program). Without `x`, users cannot `cd` into the directory or access files inside it - even if the files themselves have open permissions.

---

## Core Commands

```bash
# Check file permissions
ls -l /path/to/file

$ Check directory permissions (shows the dir itself, not contents)
ls -ld /path/to/directory

# Change permissions
sudo chmod 755 /path/to/file

## Change owner and group
sudo chown owner:group /path/to/file

## Add user to a group (always use -aG together)
sudo usermod -aG groupname username

## Create a new group
sudo groupadd groupname

# Check group membership
sudo passwd -l username

# Unlock a user account
sudo passwd -U username

# Check account status (L=locked, P=active)
sudo passwd -S username

# Safely edit sudoers
sudo visudo

# Check what sudo commands a user can run
sudo -l -U username

# Set SUID bit 
sudo chmod u+s /path/to/file

# Set SGID bit
sudo chmod g+s /Path/to/file
```

---

## Scenarios Practised

### Scenario 1 - user Removed from Sudo Group 
**Problem:** Developer can't run sudo commands - was working yesterday.
**Diagnose:** `groups devuser` - `sudo` missing from the group list.
**Fix:** `sudo usermod -aG sudo devuser` 
**Verify:** `groups devuser` - confirm `sudo` is back in the list.

---

### Scenario 2 - File Permission Denied
**Problem:** Developer can't read `/opt/appdata/config.txt`.
**Diagnose:** `ls -l /opt/appdata/config.txt` - others had `---` (no permissions at all).
**Fix:**
```bash
sudo groupadd appteam
sudo usermod -aG appteam devuser
sudo chown root:appteam /opt/appdata/config.txt
# Permissions were already 640 - group has r--
```
**Verify:** `ls -l /opt/appdata/config.txt` - confirm group is `appteam`.

---

### Scenario 3 - Critical System File Broken
**Problem:** Junior admin ran `sudo chmod 000 /etc/passwd` - no one can log in.
**Diagnose:** `ls -l /etc/passwd` - all permissions removed (`--------`).
**Fix:** `sudo chmod 644 /etc/passwd`
**Verify:** `ls -l /etc/passwd` - confirm `-rw-r--r--`.

> `/etc/passwd` must always be `644` - every user on the system needs to read it during login.

---

### Scenario 4 - Script Not Executable
**Problem:** Developer can't execute `/opt/scripts/deploy.sh`
**Diagnose:** `ls-l /opt/scripts/deploy.sh` - permissions were `644`, no execute bit.
**Fix** `sudo chmod 744 /opt/scripts/deploy.sh`
**Verify:** `ls -l` - confirm `-rwxr--r--`.

---

### Scenario 5 - Account Locked
**Problem:** Developer can't log in despite entering the correct password.
**Diagnose:** `sudo passwd -S devuser` - status showed `L` (locked).
**Fix:** `sudo passwd -U devuser`
**Verify:** `sudo passwd -S devuser` - confirm status shows `p`.

### Scenario 6 - Directory Not Accessible 
**Problem:** Permission denied when trying to access `/opt/appdata/`.
**Diagnose:** `ls -ld /opt/appdata` - permission were `644` (missing execute bit on directory).
**Fix:** `sudo chmod 755 /opt/appdata`
**Verify:** `ls -ld /opt/appdata` - confirm `drwxr-xr-x`.

---

### Scenario 7 - File Not Writable
**Problem:** Developer can't write to `/var/log/app.log`.
**Diagnose:** `ls -l /var/log/app.log` - others had `r--` (read only).
**Fix:**
```bash
sudo groupadd applog
sudo usermod -aG applog devuser
sudo chown root:applog /var/log/app.log
sudo chmod 664 /var/log/app.log
```
**Verify:** `ls -l /var/log/app.log` - confirm `-rw-rw-r--` with group `applog`.

---

### Scenario 8 - Restricted Sudo Access
**Problem:** Developer needs to restart nginx but should not have full sudo access.
**Fix:** `sudo visudo` -> add at the bottom:
```
devuser ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
```
**Verify:** `sudo -l -U devuser` - confirm only that specific command is listed.

---

### Scenario 9 - SUID Bit
**Problem:** A script must run as root regardless of who executes it - without giving the user full sudo. 
**Fix:** `sudo chmod u+s /opt/scripts/deploy.sh`
**Verify:** `ls -l /opt/scripts/deploy.sh` - confirm `s` in owner execute position -> `-rwsr-xr-x`.

---

## Troubleshooting

**`su - devuser -c "sudo whoami"` returned password error**
Sudo requires an interactive terminal to prompt for a password. Running it non-interactively via `su -c` fails. This is expected behaviour - not a sign the fix was wrong. Verify group membership with `groups devuser` instead.

**`passwd -S` without username showed wrong user**
Running `passwd -S` without specifying a username defaults to the currently logged-in user, not the user you just modified. Always specify the Username: `sudo passwd -S devuser`.

---

## Skills Gained

- Reading and interpreting `ls -l` and `ls -ld` output to diagnose permission problems
- Understanding numeric (octal) permission notation and converting between numeric and symbolic
- Knowing the difference between file permissions and directory permissions (x = enter on directories)
- Using `chmod` and `chown` to fix file and directory permissions
- Creating groups and using group-based access control `usermod` - never `-G` alone
- Understanding that group membership changes require a fresh login to take effect 
- Locking and unlocking user accounts with `passwd -l`, `-U`, and `-S`
- Safely editing `/etc/sudoers` with `visudo` and writing command-specific sudo rules
- Understanding SUID and SGID bits and when to use them

---

## Environment Used

| Component | Detail |
|---|---|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Key Files | /etc/passwd, /etc/sudoers, /opt/appdata/, /var/log/app.log |
| Key Tools | chmod, chown, usermod, groupadd, passwd, visudo |
