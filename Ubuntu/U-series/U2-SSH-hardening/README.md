# U2 - SSH Hardening

## Objective
Secure remote server access using SSH hardening technique

## Topics Covered

- OpenSSH server configuration
- Key-based authentication
- Disabling password authentication
- Changing default SSH port
- Disabling root login
- Monitoring SSH logs

## Key Commands

systemctl status ssh
systemctl restart ssh
ssh-keygen
ssh-copy-id
journalctl -u ssh

## SSH key Authentication

Generate key pair

ssh-keygen -t ed25519

Copy key to server

ssh-copy-id user@server-ip

## SSH Configuration File

/etc/ssh/sshd_config

Important settings: 

PermitRootLogin no
PasswordAuthentication no
Port 2222

Restart SSH after changes

sudo systemctl restart SSH

## Log Monitoring

journalctl -u ssh

Authentication logs

/var/log/auth.log

## Lab

1. Create secondary user
2. Generate SSH key
3. Configure key authentication
4. Disable password login
5. Test login from another machine

## Skills Gained

- Secure remote server access
- SSH key authentication
- SSH attack prevention basics
