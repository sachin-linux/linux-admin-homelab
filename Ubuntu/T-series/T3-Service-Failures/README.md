# T3- Service Failures

## What This Module Coveres 
Real-world service failure troubleshooting scenarios - diagnosing and fixing broken services the way you would on the job.

---

## Scenarios Completed

**Scenario 1 - Port Conflict (nginx vs apache2)**
- Problem: nginx fails to start, users getting getting connnection refused
- Diagnose: `systemctl stataus nginx` -> `bind() failed (98: Address already in use)`
- Investigate: `sudo ss -tulnp | grep :80 -> apache2 occupying port 80
- Fix: `sudo systemctl stop apache2` then `sudo systemctl start nginx`
- Bonus: Change nginx port by editing `listen 80` in `/etc/nginx/sites-available/default`

**Scenario 2 - Missing Application File**
- Problem: myapp service fails immediately on start
- Diagnose: `journalctl -xeu myapp` -> `can't open file '/opt/myapp.py': No such file or directory`
- Fix: `sudo touch /opt/myapp.py` then add content so the process stays running
- Root cause: ExecStart was pointing to a file that didn't exist 

**Scenario 3 - Typo in Service File**
- Problem: Service won't start after someone edited the service file
- Diagnose: `systemctl status myapp` -> `status=203/EXEC`
- Investigate: ExecStart line had `/usr/bin/python3/opt/myapp.py` (missing space)
- Fix: `sudo nano /etc/systemd/system/myapp.service` -> correct the ExecStart line
- Then: `sudo systemctl daemon-reload -> `sudo systemctl start myapp`

**Scenario 4 - Service Not Enabled at Boot**
- Problem: Service works fine manually but dies after every reboot
- Diagnose: `systemctl status myapp` -> Loaded line shows `disabled`
- Fix: `sudo systemctl enable myapp`
- Verify: `systemctl status myapp` -> Loaded line now shows `enabled`

**Scenario 5 - Application Crashing (exit code 1)**
- Problem: Service works fine manually but dies after every reboot
- Diagnose: `systemctl status myapp` -> Loaded line shows `disabled`
- Root cause: Python script calling `sys.exit(1)` - app itself crashing
- Fix: Correct the application code so it doesn't exit with an error
- Tool used: `journalctl -fu myapp` to follow logs live in real time

**Scenario 6 - Stale Service Config (daemon-reload)**
- Problem: Edited a service file but systemd is using the old version
- Symptom: `Warning: The unit file, source configuration file or drop-ins of myapp2.service changed on disk`
- Fix: `sudo systemctl daemon-reload` then `sudo systemctl restart myapp2`
- Verify: `systemctl status myapp2` -> description shows updated text

**Scenario 7 - No Auto-Restart on Crash**
- Problem: Service stays dead after crashing - needs manual intervention every time
- Fix: Add `Restart=always` to the `[Service]` section of the service file
- Then: `sudo system daemon-reload` -> `sudo systemctl restart myapp`
- Verify: `sudo kill -9 $(pgrep -f myapp.py)` -> `restart counter is at 1`

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `systemctl status <service>` | Check service state and recent logs |
| `systemctl start <service>` | Start the service now |
| `systemctl stop <service>` | Stop the service |
| `systemctl restart <service>` | Stop and start the service |
| `systemctl enable <service>` | Enable service to start on boot |
| `systemctl disable <service>` | Disable from starting on boot |
| `systemctl daemon-reload` | Reload systemd after editing a service file |
| `journalctl -xeu <service>` | Full logs with explanations |
| `journalctl -fu <service>` | Follow logs live in real time |
| `sudo ss -tulnp | grep :<port>` | Find what process is using a port |
| `sudo sshd -t` equivalent for services | Read ExecStart carefully + check journalctl |

---

## Service File Structure

```
[Unit]
Description=My App Service

[Service]
ExecStart=/usr/bin/python3 /opt/myapp.py
Restart=on-failure

[Install]
Wantedby=multi-user.target
```

Service files live at: `/etc/systemd/system/<name>.service`

Always run `daemon-reload` after editing a service file before restarting.

---

## Restart Options

| Value | Behaviour |
|-------|-----------|
| `Restart=no` | Never restart (default if not set) |
| `Restart=always` | Always restart no matter what |
| `Restart=on-failure` | Restart only when it exits with an error |
| `Restart=on-abnormal` | Restart on signals, timeouts, or watchdog |

---

## Exit Codes

| Code | Meaning | Where to Look |
|------|---------|---------------|
| `status=1/FAILURE` | App exited with an error | Check app logs or script |
| `status=2/INVALIDARGUMENT` | Wrong arguments or file not found | Check ExecStart path |
| `status=203/EXEC` | Binary or path in ExecStart doesn't exist | Fix the path in service file |
| `Result: exit-code` | General failure on start | Read the log lines below it |

---

## Troubleshooting Workflow

1. `systemctl status <service>` - check state and exit code
2. `journalctl -xeu <service>` - read the full error message
3. `ss -tulnp | grep :<port> ` - if port conflict suspected
4. Fix the issue (service file, app, port, or config)
5. `systemctl daemon-reload` - if you edited the service file
6. `systemctl restart <service>` + `status` - verify it's runnign 

---

## Golden Rules 

- `start` runs the service NOW. `enable` makes it survive reboots. Always use both in production.
- `203/EXEC` almost always means the path in ExecStart is wrong - check it first.
- `journalctl -fu <service>` is your best friend for live debugging a crashing service.
- Always run `daemon-reload` after editing a service file - never skip it.
- `bind() failed: Address already in use` = port conflict - use `ss -tulnp` to find the culprit.
- Add `Restart=on-failure` or `Restart=always` to every production service.

---

## Environment Used

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Key Files | `/etc/systemd/system/`, `/etc/nginx/sites-available/default`, `/opt/myapp.py` |
| Key Tools | systemctl, journalctl, ss, nano, kill | 

