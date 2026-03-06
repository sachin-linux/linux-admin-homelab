# Lab Title: U4 – Systemd Services

## Objective
Manage system services using systemd and create custom service units.

## Prerequisites
- Ubuntu server running
- Sudo access

## Steps / Instructions

### 1. Check SSH Service
sudo systemctl status ssh

### 2. Start, Stop, Enable, Disable Services
sudo systemctl start service_name
sudo systemctl stop service_name
sudo systemctl enable service_name
sudo systemctl disable service_name

### 3. Create a Custom Service
Create /etc/systemd/system/hello.service:
[Unit]
Description=Hello Service
[Service]
ExecStart=/usr/local/bin/hello.sh
[Install]
WantedBy=multi-user.target
Reload systemd and enable:
sudo systemctl daemon-reload
sudo systemctl enable hello
sudo systemctl start hello

### 4. Test Service
sudo systemctl status hello

## Commands Used
systemctl status, start/stop/enable/disable, daemon-reload

## Skills Learned
- Systemd basics
- Managing services
- Creating custom service units
- Logging and troubleshooting

## Result / Verification
Custom service running successfully and logs verified.
