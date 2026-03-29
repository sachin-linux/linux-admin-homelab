# T6 - Network Troubleshooting

What This Module Covers
Real-world network troubleshooting scenarios - diagnosing connectivity, DNS, firewall, and SSH config issues the way you would on the job.

---

### Scenarios Completed 

### Scenarios 1 - The Ghost Network
**Problem:** Colleague reports SSH is unreachable and server has no internet. Was working fine yesterday.

**Investigate:** `ip addr` -> enp0s3 state DOWN, no IP assigned

**Found:** 
- Network interface enp0s3 was in state DOWN
- No IP address assigned - routing and SSH both impossible

**Fix:** `sudo ip link set enp0s3 up` -> DHCP restored IP and default route automatically

**Key lesson:** On a DHCP system, bringing the interface up restores everything automatically. On a static IP server, you also need to restore the default route manually with `ip route add default via <gateway>`

---

### Scenario 2 - DNS Failure
**Problem:** Server can ping 8.8.8.8 but websites and apt updates are completely broken.

**Investigate:**
```
ping -c 2 8.8.8.8		-> Success
ping -c 2 google.com		-> Temporary failure in name resolution
nslookup google.com		-> Connection refused to 127.0.0.1#53
systemctl status sysytemd-resolved -> inactive (dead)
cat /etc/resolv.conf		-> No such file or directory
```

**Found**
- systemd-resolved service was stopped
- /etc/resolv.conf symlink was deleted

**Fix:**
```
sudo systemctl start systemd-resolved
sudo ln -srf /run/systemd/resolv/stub-resolv.conf /etc/resolv.conf
```

**Key lesson:** /etc/resolv.conf on Ubuntu is a symlink, not a regular file. Using touch to recreate it will not work - must restore it with ln -sf pointing to the systemd-resolved stub resolver

---

### Scenario 3 - Firewall Blocking SSH
**Problem:** SSH connection refused after UFW rule changes. Server unreachable remotely.

**Investigate:** `sudo ufw status verbose` ->
```
2222/tcp	ALLOW IN 	Anywhere	<- runs FIRST, wins
2222		DENY IN		Anywhere	<- never reached
```

**Found:** UFW in first-match-wins - existing ALLOW rule for port 2222 was above the DENY, so DENY had no effect

**Fix:**
```
sudo ufw delete allow 2222/tcp 	(applied via VM console - locked out of SSH)
sudo ufw allow 2222/tcp		(restore access after fixing)
```

**Key lesson:** Always check UFW rule order with `ufw status verbose` before trusting a DENY rule. Never block your SSH port without console access as fallback - in production use AWS Session Manager, IPMI/iDRAC, or VPS VNC console

---

### Scenario 4 - SSH Config Drop-in Override
**Problem:** PasswordAuthentication on set in sshd_config but users could still log in with passwords.

**Investigate:**
```
sudo grep PasswordAuthentication /etc/ssh/sshd_config
-> PasswordAuthentication no (looks correct)

sudo grep -r PasswordAuthentication /etc/ssh/sshd_config.d/
-> /etc/ssh/sshd_config.d/50-cloud-init.conf: PasswordAuthentication yes <- overrides main config
```

**Found:** 50-Cloud-init.conf in sshd_config.d/ was overriding the main config. Files in that directory are loaded after sshd_config and take precedence.

**Fix:**
```
sudo sed -i `s/PasswordAuthentication yes/PasswordAuthentication no/` /etc/ssh/sshd_config.d/50-cloud-init.conf
sudo systemctl restart sshd
```

**Verify:** `ssh -p 2222 -o PreferredAuthentications=password -o PubKeyAuthentication=no user@192.168.0.101` -> Permission denied (publickey) 

**Key lesson:** Always check /etc/ssh/sshd_config.d/ for drop-in overrides - Ubuntu's cloud-init installs 50-cloud-init.conf which can silently undo hardening changes made to the main sshd_config

---

## Key Commands 

| Command | Purpose |
|---|---|
| `ip addr` | Check interface status and IP assignment |
| `ip link set enp0s3 up/down` | Bring network interface up or down |
| `ip route show` | View the routing table |
| `ping -c 2 8.8.8.8` | Test IP-level connectivity |
| `ping -c 2 google.com` | Test DNS resolution |
| `nslookup google.com` | Diagnose DNS resolution issues |
| `systemctl status systemd-resolved` | Check DNS resolver service status |
| `sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf` | Restore resolv.conf symlink |
| `sudo ufw status verbose` | View UFW rules with order — critical for debugging |
| `sudo ufw allow/deny PORT/tcp` | Add a UFW firewall rule |
| `sudo ufw delete allow PORT/tcp` | Remove a UFW firewall rule |
| `sudo grep -r PasswordAuthentication /etc/ssh/sshd_config.d/` | Check SSH drop-in config overrides |
| `sudo systemctl restart sshd` | Restart SSH after config changes |
| `ss -tulnp` | Show all listening ports and services |
| `ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host` | Test password-only SSH login |

---

## SSH Config File Locations

| File | What It Controls |
|---|---|
| `/etc/ssh/sshd_config` | Main SSH server config — read first |
| `/etc/ssh/sshd_config.d/` | Drop-in directory — files here override main config |
| `/etc/ssh/sshd_config.d/50-cloud-init.conf` | Cloud-init SSH settings — often overrides hardening |
| `/run/systemd/resolve/stub-resolv.conf` | systemd-resolved stub — target for resolv.conf symlink |
| `/etc/resolv.conf` | DNS resolver config — must be a symlink on Ubuntu |

---

## Network Troubleshooting Workflow

- `ip addr` - is the interface UP? Does it have an IP?
- `ping 8.8.8.8` - tests IP connectivity and routing
- `ping google.com` - if this fails but 8.8.8.8 works, it is DNS
- `nslookup google.com` - Confirms DNS failure and shows which resolver is used
- `systemctl status systemd-resolved` - check if DNS service is alive
- `cat /etc/resolv.conf` - check if the symlink exists
- `sudo ufw status verbose` - Check firewall rules and their order
- `sudo grep -r <setting> /etc/ssh/sshd_config.d/` - Check for SSH config overrides

---

## Golden Rules

- ping IP works but ping domain fails - always DNS first 
- UFW is first-match-wins - always check rule order with ufw status verbose before trusting a DENY rule
- Never block SSH without console access a backup
- /etc/resolv.conf on Ubuntu is a symlink - restore it with ln -sf, never with touch
- Always check /etc/ssh/sshd_config.d/ - drop-in files override the main config silently
- ip addr showing DOWN means no IP, no routing, no SSH - bring the interface up first
- DHCP systems auto-heal routes when interface comes back up - static IP systems do not

---

## Environment Used

| Component | Detail |
|---|---|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| SSH Port | 2222 |
| VM IP | 192.168.0.101 |
| Key Tools | ip, ping, nslookup, ufw, systemctl, ss, grep, sed |
