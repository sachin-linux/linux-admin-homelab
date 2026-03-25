# T2 - SSH Access Problems

## What This Module Covers

Real-world SSH troubleshooting scenarios - diagnosin and fixing broken SSH access the way you would on the job. 

---

## Scenarios Completed

### Scenario 1 - SSH Service Not Running
- **Problem:** User cannot SSH in at all
- **Diagnose:** `systemctl status ssh` -> inactive (dead)`
- **Fix:** `sudo systemctl start ssh`

### Scenario 2 - Bad SSH Config Syntax
- **Problem:** SSH won't start after a config edit
- **Diagnose:** `sudo sshd -t` -> points to exact line and error
- **Fix:** Correct the bad value in `/etc/ssh/sshd_config`, restart SSH

### Scenario 3 -  Wrong Key File Permissions
- **Problem:** Key-based auth failing with `Permission denied (publickey)
- **Diagnose:** `sudo ls -ld ~/.ssh` -> `drwxrwxrwx` (too open)
- **Fix:** `chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/authorized_keys`

### Scenario 4 - AllowUsers Blocking Login
- **Problem:** Specific user defined SSH immediately
- **Diagnose:** `sudo grep -i "allowusers" /etc/ssh/sshd_config` -> user not listed
- **Fix:** Update or remove the `AllowUsers` line, restart SSH

### Scenario 5 - Firewall Blocking SSH Port
- **Problem:** `Connection refused` on SSH
- **Diagnose:** `sudo ufw status` -> port `2222 DENY`
- **Fix:** `sudo ufw allow 2222`

### Scenario 6 - SSH Connection Dropping on Inactivity
- **Problem:** SSH session drops after a few minutes of inactivity
- **Diagnose:** `sudo grep -i "clientalive" /etc/ssh/sshd_config` -> commented out or set to 0 
- **Fix:** Set `ClientAliveInterval 60` and `ClientAliveCountMax 3` in sshd_config

### Scenario 7 - Setting Up Key-Based Auth
- **Problem:** Developer wants passwordless SSH login
- **Steps:**
  1. Check for existing keys: `ls ~/.ssh/`
  2. Copy public key to server: `ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 user@host`
  3. Test login: `ssh -i ~/.ssh/id_ed25519 -p 2222 user@host`

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `systemctl status ssh` | Check SSH service status |
| `sudo systemctl start/restart ssh` | Start or restart SSH |
| `sudo sshd -t` | Test sshd_config for syntax errors |
| `sudo grep -i "setting" /etc/ssh/sshd_config` | Search SSH config quickly |
| `sudo ufw status` | Check firewall rules |
| `sudo ufw allow PORT` | Open a port in the firewall |
| `ssh-copy-id -i key.pub -p PORT user@host` | Copy public key to remote server |
| `ssh -i key -p PORT user@host` | SSH using a specific key |

---

### SSH File Permissions Rules

| Path | Permission | Meaning |
|------|-----------|---------|
| `~/.ssh/` | `700` | Only owner can access |
| `~/.ssh/authorized_keys` | `600` | Only owner can read/write |
| `~/.ssh/id_ed25519` (private key) | `600` | Never readable by others |
| `~/.ssh/id_ed25519.pub` (public key) | `644` | Readable by all |

> SSH silently rejects key auth if permissions are too open - no obvious error, just `Permission denied`.

---

## Error Types

| Error | Likely Cause |
|-------|-------------|
| `Connection refused` | Firewall blocking or SSH service down |
| `Permission denied (publickey)` | Wrong key permissions or key not in authorized_keys |
| `Permission denied (password)` | Wrong password, account locked, or password auth disabled |
| `Connection timed out` | Network issue or firewall dropping packets silently |
| Config syntax error on start | Bad value in sshd_config — run `sudo sshd -t` |

---

## Key sshd_config Settings

| Setting | Effect |
|---------|--------|
| `Port 2222` | SSH listens on non-default port |
| `AllowUsers user1 user2` | Only listed users can SSH in |
| `DenyUsers user1` | Blocks specific users |
| `PermitRootLogin no` | Root cannot SSH in directly |
| `PasswordAuthentication no` | Keys only — no password login |
| `ClientAliveInterval 60` | Keepalive every 60 seconds |
| `ClientAliveCountMax 3` | Disconnect after 3 missed keepalives |

--- 

## Golden Rules 

- Always run `sudo sshd -t` before restarting SSH after any config change
- `Connection refused` = firewall or service down. `Permission denied` = auth/config issue
- SSH silently rejects keys if `.ssh` or `authorized_keys` permissions are too open
- `AllowUsers` is a whitelist - if set, unlisted users are denied automatically
- `ClientAliveInterval` should always be set in production to prevent dropped connections

---

## Environment Used

| Component | Detail |
|---|---|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| SSH Port | 2222 |

