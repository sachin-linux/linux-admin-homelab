# U4 – Systemd Services Lab

## Objective
Learn to create, manage, and monitor custom Linux services using systemd.

---

## Lab Environment

- Ubuntu Server
- VirtualBox
- Root or sudo access

---

## Step 1 – Check Existing Services

```bash
systemctl list-units --type=service
systemctl status ssh
```

---

## Step 2 – Create Script for Service

```bash
sudo nano /usr/local/bin/hello.sh
```

Add:

```bash
#!/bin/bash
while true
do
  echo "Hello Sachin - Systemd Service Running" >> /tmp/hello.log
  sleep 10
done
```

Make it executable:

```bash
sudo chmod +x /usr/local/bin/hello.sh
```

---

## Step 3 – Create systemd Service File

```bash
sudo nano /etc/systemd/system/hello.service
```

Add:

```ini
[Unit]
Description=Hello Systemd Service
After=network.target

[Service]
ExecStart=/usr/local/bin/hello.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

---

## Step 4 – Reload systemd and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl start hello
sudo systemctl status hello
```

Expected:

```text
Active: active (running)
```

Enable at boot:

```bash
sudo systemctl enable hello
```

---

## Step 5 – Monitor Logs

```bash
tail -f /tmp/hello.log
```

You should see repeating lines:

```
Hello Sachin - Systemd Service Running
```

---

## Step 6 – Stop and Disable Service

```bash
sudo systemctl stop hello
sudo systemctl disable hello
```

---

## Commands Learned

- systemctl start/stop/status
- systemctl enable/disable
- systemctl daemon-reload
- tail -f /tmp/hello.log

---

## Skills Learned

- Creating custom Linux services
- Running scripts as background services
- Service startup at boot
- Monitoring service logs
