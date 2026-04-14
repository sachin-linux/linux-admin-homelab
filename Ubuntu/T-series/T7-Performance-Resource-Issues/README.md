# T7 Performance Resource Issues

## What is Performance Troubleshooting?
When a Linux Server feels slow, laggy, or unresponsive - something is consuming resources it shouldn't be. Performance troubleshooting means identifying *what* is overloading the system, *why* it's happennig, and fixing it in the right order.

---

## Why It Matters
Resources issues are among the most common real-world Linux problems. A rogue process, a full disk, or a cron job gone wrong can bring down a production server. Knowing how to diagnose fast is a core sysadmin and DevOps skill.

---

## Key Concepts

| Concept | What It Means |
|---|---|
| Load Average | Average processes waiting for CPU — compare against nproc |
| nproc | Number of CPU cores — load average only makes sense with this |
| I/O Wait (wa%) | CPU idle waiting for disk — disk is the bottleneck, not CPU |
| OOM Killer | Linux kills processes when RAM + swap are exhausted |
| Zombie Process | Finished process not yet reaped by its parent — Z state in ps |
| Nice Value | Process priority — -20 (highest) to 19 (lowest) |
| cron.d | System-wide cron job directory — source of rogue scheduled processes |

---

## Core Commands

| Command | Purpose |
|---|---|
| `top -bn1 \| head -15` | CPU, memory, top processes snapshot |
| `ps aux --sort=-%cpu \| head -10` | Top CPU consumers |
| `ps aux --sort=-%mem \| head -10` | Top memory consumers |
| `nproc` | Number of CPU cores |
| `uptime` | Load average (1/5/15 min) |
| `free -h` | RAM and swap usage |
| `df -h` | Disk usage per filesystem |
| `du -sh /path/*` | Directory size breakdown |
| `pkill <name>` | Kill all processes by name |
| `sudo rm /etc/cron.d/<file>` | Remove rogue cron job |
| `dmesg \| grep -i oom` | OOM killer history |
| `ps aux \| awk '$8=="Z"'` | Find zombie processes |
| `iostat -x 1 3` | Per-disk I/O statistics |
| `sudo iotop -o` | Per-process I/O usage |
| `nice -n 19 <cmd>` | Start process at low priority |
| `sudo renice -n 10 -p <pid>` | Change priority of running process |

---

## Lab Summary

### Scenario 1 - CPU Overload
**Problem:** Server extremely slow, commands lagging.
**Investigation:** `ps-aux --sort=-%cpu`, `top`, `nproc`
**Found:** gzip at 88% CPU + multiple sha256sum processes at 25-97% each. Load average 4.89 on a 2-core VM = 2.4x overload.
**Fix:** Removed `/etc/cron.d/haunted` first (source), then `pkill sha256sum && pkill gzip`
**Key lesson:** Kill the source before killing the process. Cron respawns every minute.

### Scenario 2 - Disk Space Exhaustion
**Problem:** Root filesystem at 91%, only 1.8G free.
**Investigation:** `df-h`, `ls -lh /tmp/`
**Found:** 500MB junkfile in /tmp created by `dd if=/dev/zero`
**Fix:** `rm /tmp/junkfile`
**Key lesson:** Check /tmp and /var/log first. At 100% disk the system cannot write anything.

### Scenario 3 - Zombie Processes
**Problem:** Processes accumulating in Z state.
**Investigation:** `ps aux | awk '$8=="z"'`
**Found:** Parent process not calling wait() to reap finished children.
**Fix:** `sudo kill -SIGCHILD <parent_pid>` - signal parent to recap. Cannot kill a zombie directly.
**Key lesson:** Zombies are already dead. Fix is always at the parent level.

### Scenario 4 - OOM Killer
**Problem:** Processes dying randomly. `dmseg` shows OOM activity.
**Investigation:** `free -h`, `dmseg | grep -i oom`
**Found:** RAM and SWAP exhausted, Python memory leak consumed all available memory.
**Fix:** OOM killer acted automatically. Long term: fix the leak, add swap, add RAM.'
**Key lesson:** `dmseg` is your evidence log when processes die mysteriously.

### Sceanrio 5 - High I/O Wait
**Problem:** Server slow but CPU looks idle. `top` shows high `wa%`.
**Investigation:** `iostat -x 1 3`, sudo iotop -o`
**Found:** Disk I/O saturated - CPU waiting for disk, not actually doing work.
**Fix:** Kill the I/O hog, Long term: SSD, ionice, optimise application I/O.
**Key lesson:** High wa% + low CPU = disk bottleneck. Don't confuse slow server with CPU problem.

### Scenario 6 - Runaway Cron Job
**Problem:** New processes spawning every minute even after killing them.
**Investigation:** `ls /etc/cron.d/`, `cat /etc/cron.d/<file>`
**Found:** `* * * * *` cron job running sha256sum as root - new process every 60 seconds.
**Fix:** `sudo rm /etc/cron.d/haunted` then `pkill sha256sum`
**Key lesson:** The cron file is the root cause. Running processes are just symptoms.

### Scenario 7 - Process Priority (Nice)
**Concept:** Heavy background jobs should run at low priority so they don't compete with user-facing services.
**Commands:** `nice -n 19 <cmd>` to start low, `sudo renice -n 10 -p <pid>` to adjust live.
**Key lesson:** Nice value -20 = higest priority, 19 = lowest. Default is 0.

---

## File Modified / Created

| File | Action |
|---|---|
| `/etc/cron.d/haunted` | Created (break), removed (fix) |
| `/tmp/junkfile` | Created by dd (break), removed (fix) |

---

## Result

```
$ uptime
05:48:35 up 21 min, 1 user, load average: 0.26, 5.28, 5.11

$ df -h /
Filesystem		 	     Size   Used  Avail  Use%
/dev/mapper/Ubuntu--vg-ubuntu--lv     20G    17G   2.3G   89%

$ top -bn1 | head -5 
%Cpu(s): 4.8 us, 9.5 sy, 0.0 ni, 85.7 id, 0.0 wa
```
Load recovered. CPU idle at 85.7%. Disk junk cleared.

---

## Troubleshooting Encountered

| Issue | What Happened |
|---|---|
| Permission denied on /etc/cron.d/ | Used `sudo tee` instead of direct redirect |
| Python memory process auto-killed | OOM killer acted before manual kill — expected behaviour |
| Load average still high after fix | Rolling average takes time to drop — 1-min value recovers fastest |

---

## Golden Rules

1. **Load average means nothing without nproc:** - always check both
2. **Kill the source before killing the process** - find where it comes from
3. **High wa% with low CPU = disk bottleneck**, not CPU problem
4. **You cannot kill a zombie** - kill or signal the parent
5. **Disk at 90%+ is an emergency** - check /tmp and /var/log first
6. **pkill by name** - faster than hunting PIDs when multiple instances exist
7. **Cron file is the root cause:** running processes are symptoms

---

## Skills Gained

- Reading and interpreting `top` output (CPU states, load average, process stats)
- Correlating load average with nproc to assess real system load
- Identifying and killing rogue processes with `ps`, `top`, `pkill`
- Locating and removing rogue cron jobs from `/etc/cron.d/`
- Diagnosing disk exhaustion with `df -h` and `du -sh`
- Understanding zombie processes and OOM killer behavious
- Distinguishing CPU bottleneck vs I/O wait bottleneck
- Adjusting process priority with `nice` and `renice`

---

## Environment Used

| Item | Detail |
|---|---|
| OS | Ubuntu (LVM) |
| SSH Port | 2222 |
| CPU Cores | 2 |
| RAM | ~3.9 GB |
| Root Disk | /dev/mapper/ubuntu--vg-ubuntu--lv — 20G LVM |
| Date | April 2026 |
 
