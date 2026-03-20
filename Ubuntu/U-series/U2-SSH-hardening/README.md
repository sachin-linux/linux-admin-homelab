# U2 - SSH Hardening

## Objective
Secure remote server access using SSH hardening technique

---


## Topics Covered

- OpenSSH server configuration
- Key-based authentication
- Disabling password authentication
- Changing default SSH port
- Disabling root login
- Monitoring SSH logs

---


## Key Commands

| Command | Purpose |
|---------|---------|
| `systemctl status ssh` | Check SSH service status |
| `systemctl restart ssh` | Restart SSH service |
| `ssh-keygen` | Generate SSH key pair |
| `ssh-copy-id` | Copy public key to server |
| `journalctl -u ssh` | View SSH logs |

---


## SSH key Authentication

###Generate key pair
```bash
ssh-keygen -t ed25519
```

###Copy key to server

ssh-copy-id user@server-ip

## SSH Configuration File
```bash
/etc/ssh/sshd_config
```

###Important settings: 
```bash
PermitRootLogin no
PasswordAuthentication no
Port 2222
```

###Restart SSH after changes
```bash
sudo systemctl restart SSH
```

---


## Log Monitoring
```bash
journalctl -u ssh		# view SSH logs
/var/log/auth.log		# View authentication logs
```

---


## Lab

1. Create secondary user
2. Generate SSH key
3. Configure key authentication
4. Disable password login
5. Test login from another machine

---


## Skills Gained

- Secure remote server access
- SSH key authentication
- SSH attack prevention basics

--- 

## Environment Used 
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
