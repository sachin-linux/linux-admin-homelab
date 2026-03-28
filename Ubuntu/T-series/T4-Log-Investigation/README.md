# T4 Log Investigation

## What This Module Covers
Real-world log investigation scenarios - diagnosing system issues by reading and filtering logs the way you would on the job.

---

## Scenarios Completed

### Scenario 1 - Multi-Issue Investigation

- **Problem:** colleague left a note - app was acting weird, service may have restarted, suspicious login attempts overnight
- **Investigate:** `grep -i "error|failed|warning|critical" /var/log/syslog/ | tail -30`
- **Found:** 
  - SSH brute force - invalid user `hacker` from `192.168.1.105`, 5 failed attempts
  - `myapp.service` crashed with `Failed with result exit-code` then restarted
  - Kernel error - `EXT4-fs error (device sda1): ext4_find_entry` - filesystem errors on disk
  - Cron failure - `getpwnam() failed for user badcronuser` - cron job for a non-existent user
  - **Key lesson:** Not every WARNING is a real problem - GRUB boot detection shows as "failed" but is normal system noise

---

### Scenario 2 - Cron Job That Never Run

- **Problem:** Backup script set to run every night at 2am, never created any backup files
- **Investigate:** `grep "sshd" /var/log/syslog | grep -i "failed|accepted"`
- **Found:**
  - Attacker 1 - `10.0.0.55`: 8 failed attempts as `admin`, 3 failed attempts as `root`, then **successful login as `user`**
  - Attacker 2 - `203.0.113.0`: 4 failed attempts as `ubuntu`
- ** Response steps:**
  - Block both IPs: `sudo ufw deny from 10.0.0.55` and `sudo ufw deny from 203.0.113.9`
  - Change compromised user password: `sudo passwd user`
  - Check login history: `last | grep 10.0.0.55`
- **Key lesson:** `Accepted password` in the logs means someone got in - treat it as an incident

---

### Scenario 4 - Disk Almost Full

- **Problem:** Alert that disk is alomost full - unknown what's eating the space
- **Diagnose:** `df -h` -> `/` partition at 91% used
- **Find culprits:** `sudo du -sh /var/log/* | sort -rh | head -10`
- **Found:**
  - `/var/log/journal` - 483M (grows without a size limit)
  - `/var/log/biglog2.log` - 51M (not a real log file)
  - `/var/log/biglog2.log` - 50M (not a real log file)
  - `/tmp/dumpfile.tmp` - 30M
- **Fix:** `sudo rm /var/log/biglog1.log /var/log/biglog2.log /tmp/dumpfile.tmp`
- **Fix journal:** `sudo journalctl --vacuum-size=100M` -> freed ~400M, dropped from 91% to 88%
- **Key lesson:** `/var/log/journal` growns forever - set `SystemMaxUse= in` in `/etc/systemd/journald.conf` to cap it

---

### Scenario 5 - App Errors Overnight

- **Problem:** Developer says app was throwing errors between 2am and 3am - needs exact count and count and details
- **Investigate:** `grep "myapp" /var/log/syslog | tail -20`
- **count by severity:**
  - `grep "myapp" /var/log/syslog | grep "ERROR" | wc -l` → **5 errors**
  - `grep "myapp" /var/log/syslog | grep "WARNING" | wc -l` → **2 warnings**
  - `grep "myapp" /var/log/syslog | grep "CRITICAL" | wc -l` → **1 critical**
- **Summary:**
  - 3x `ERROR: Database connection timeout`
  - 2x `ERROR: Failed to write to cache`
  - 2x `WARNING: Retry attempt for database connection`
  - 1x `CRITICAL: Application crashed, out of memory`
  - 1x `INFO: Application restarted successfully`
- **Key lesson:** Always separate ERROR, WARNING, CRITICAL — they have different urgency and different owners

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `grep -i "error\|failed\|warning" /var/log/syslog \| tail -30` | Broad search for problems in syslog |
| `grep "sshd" /var/log/syslog \| grep -i "failed\|accepted"` | Filter SSH login events |
| `grep "appname" /var/log/syslog \| grep "ERROR" \| wc -l` | Count errors from a specific app |
| `grep -i "cron" /var/log/syslog \| tail -20` | Check cron job logs |
| `journalctl -xu servicename` | Full verbose logs for a specific service |
| `journalctl -p 3` | Show errors and above (priority 3+) |
| `journalctl -b` | Logs from current boot only |
| `journalctl -b -1` | Logs from previous boot |
| `journalctl -f` | Follow logs live in real time |
| `journalctl --vacuum-size=100M` | Shrink journal logs to free disk space |
| `df -h` | Show disk usage per filesystem |
| `du -sh /var/log/* \| sort -rh \| head -10` | Find largest files in /var/log |
| `sudo ufw deny from <IP>` | Block an IP address |
| `last \| grep <IP>` | Check login history for an IP |

---

## Log File Locations

| File | What It Contains |
|------|-----------------|
| `/var/log/syslog` | General system messages — services, kernel, cron, logger entries |
| `/var/log/auth.log` | Authentication — SSH logins, sudo usage, PAM |
| `/var/log/kern.log` | Kernel messages — hardware, disk, driver errors |
| `/var/log/journal` | Systemd journal — use journalctl to read |

---

## Cron Troubleshooting

| Log Entry | Cause | Fix |
|-----------|-------|-----|
| `getpwnam() failed for user X` | Cron job set for a user that doesn't exist | Create the user or remove the cron entry |
| `permission denied` | Script has no execute permission | `chmod 755 /path/to/script` |
| `No MTA installed, discarding output` | No mail server to send cron output | Normal — redirect output to a log file instead |

---

**Cron file locations:**
- `/etc/cron.d/` — system-wide cron jobs
- `/etc/crontab` — main system crontab
- `crontab -l` — list cron jobs for current user
- `crontab -l -u username` — list cron jobs for specific user

---

## SSH Brute Force Signs

- `Failed password for invalid user X` — attacker trying non-existent usernames
- `Failed password for root` — attacker targeting root directly
- `message repeated X times` — syslog shorthand for repeated identical lines
- `Accepted password` — **successful login** — check the source IP immediately

---

## Investigation Workflow

1. `grep -i "error|failed|warning|critical" /var/log/syslog | tail -30` — start broad
2. Identify the service or component from the output
3. Filter specifically — `grep "servicename" /var/log/syslog`
4. Go deep if it's a systemd service — `journalctl -xu servicename`
5. Count and categorise — `grep "ERROR" | wc -l`
6. Fix the root cause
7. Verify — `systemctl status` or `grep` again to confirm clean

---

## Golden Rules

- `syslog` first, always — it catches almost everything including cron, SSH, kernel, and custom apps
- `journalctl -xu` is the most detailed view for systemd service failures — read every line
- Not every WARNING is a problem — learn to distinguish system noise from real issues
- Cron failures are silent — they don't alert you, only show up in syslog
- An `Accepted password` from an unknown IP is an incident — act immediately
- `/var/log/journal` grows forever without a cap — set `SystemMaxUse=` in `/etc/systemd/journald.conf`
- Always use `wc -l` to give exact counts — never guess numbers in a report

---

## Environment Used

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Key Log Files | `/var/log/syslog`, `/var/log/auth.log`, `/var/log/kern.log` |
| Key Tools | `grep`, `journalctl`, `df`, `du`, `ufw`, `wc`, `logger` |
