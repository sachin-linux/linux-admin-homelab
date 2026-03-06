# Lab Title: U3 – Security Hardening & SSH

## Objective
Secure SSH access and perform basic server hardening.

## Prerequisites
- Ubuntu server with SSH running
- Access to sudo user

## Steps / Instructions

### 1. Create new user and assign sudo
adduser newuser
usermod -aG sudo newuser

### 2. Configure SSH Key Authentication
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

### 3. Disable root login and change SSH port
Edit /etc/ssh/sshd_config:
PermitRootLogin no
Port 2222
Restart SSH:
sudo systemctl restart ssh

## Commands Used
adduser, usermod, ssh-keygen, cat, sudo systemctl restart ssh

## Skills Learned
- User creation and sudo management
- SSH key-based authentication
- Basic server hardening

## Result / Verification
SSH login works with key, root login disabled, custom port applied.
