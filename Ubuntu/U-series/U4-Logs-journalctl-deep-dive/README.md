# U4 - Logs (journalctl Deep Dive)

## Objective
Understand Linux logging and diagnose system issue using logs.

---


## Topics Covered

- systemd journal
- journalctl commands
- system boot logs
- authentication logs
- log monitoring
- logrotate configuration

---


## Key Commands
| Command | Purpose |
|---------|---------|
| `journalctl` | View all journal logs |
| `journalctl -f` | Follow logs in real time |
| `journalctl -u ssh` | View logs for specific service |
| `journalctl -b` | View logs from current boot |
| `journalctl --since "1 hour ago"` | View logs from last hour |

---


## Log Locations
| File | Purpose |
|------|---------|
| `/var/log/syslog` | General system logs |
| `/var/log/auth.log` | Authentication events |
| `/var/log/kern.log` | Kernel logs |

---


## Monitoring Logs

### Follow logs in real time
```bash
journalctl -f
```

### Check SSH logs
```bash
journalctl -u ssh
```

### Check boot logs
```bash
journalctl -b
```

---


## Log Rotation 

### Main configuration file
```
/etc/logrotate.conf
```

### Application-specific configuration
```
/etc/logrotate.d/
```

---

## Lab

1. View boot logs
2. Monitor SSH authentication logs
3. Follow logs in real time
4. Trigger service restart and observe logs
5. Force log rotation

---


## Skills Gained

- Log analysis 
- Troubleshooting services via logs
- Monitoring authentication events

---

## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
