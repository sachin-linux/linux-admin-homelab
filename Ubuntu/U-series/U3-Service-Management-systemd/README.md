# U3 - Service Management (systemd)

## Objective
Understand how to manage Linux services using systemd and systemctl

---

## Topics
- systemctl commands
- Service lifecycle management 
- Enabling services at boot
- Viewing serive status
- Troubleshooting failed services
- Creating custom systemd services

---


## Key Commands

| Command | Purpose |
|---------|---------|
| `systemctl start <service>` | Start a service |
| `systemctl stop <service>` | Stop a service |
| `systemctl restart <service>` | Restart a service |
| `systemctl status <service>` | Check service status |
| `systemctl enable <service>` | Enable service at boot |
| `systemctl disable <service>` | Disable service at boot |

### Example
```bash
systemctl status nginx
```

---


## Viewing Service Logs
```bash
journalctl -u nginx
```

---


## Creating Custom Service

###Service giles are located in:
```
/etc/systemd/system/
```

###Example service file - `hello.service`
```ini
[Unit]
Description=Hello Service

[Service]
ExecStart=/usr/local/bin/hello.sh

[Install]
WantedBy=multi-user.targer
```

### Enable and start custom service
```bash
sudo systemctl enable hello
sudo systemctl start hello
```

---


## Lab

1. Install nginx
2. Start and stop the service
3. Enable service at boot
4. Create a custom systemd service
5. View service logs with journalctl

---


## Skills Gained

- Managing Linux services
- Service troubleshooting 
- Creating custom systemd services

---

## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
