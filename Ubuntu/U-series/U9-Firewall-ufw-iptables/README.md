# U9 - FIrewall (UFW / IPTABLES)

## Objective
Configure and manage firewalls in Linux systems.
Firewalls protect systems by controlling incoming and outgoing network traffic based on defined rules.
Linux Administrators use firewalls to secure services, block unauthorized access, and allow only necessary ports.


---


## Topics Covered

- Firewall fundamentals 
- Network ports and services
- Incoming vs outgoing traffic
- Default firewall politics
- Firewall rule management
- UFW (Uncomplicated Firewall) usage
- Basic iptables inspection
- Opening and closing ports
- Restricting access by IP address 


--- 


## Key Commands
| Command | Purpose |
|---------|---------|
| `ufw status` | Check firewall status |
| `ufw enable` | Enable firewall |
| `ufw disable` | Disable firewall |
| `ufw allow <port>` | Allow port |
| `ufw deny <port>` | Deny port |
| `ufw delete <rule>` | Delete a rule |
| `ufw reset` | Reset all rules |
| `ufw status numbered` | List rules with numbers |
| `ufw allow from <ip>` | Allow traffic from specific IP |
| `iptables -L` | List iptables rules |
| `ss -tuln` | Check listening ports |


---


## Labs Performed

### Lab 1 - Check firewall status
```bash
sudo ufw status
```

### Lab 2 - Enable firewall
```bash 
sudo ufw enable 
sudo ufw status 
```

### Lab 3 - Allow SSH access
```bash
sudo ufw allow 22
sudo ufw status
```

### Lab 4 - Block HTTP traffic
```bash
sudo ufw deny 80 
sudo ufw status numbered
```

### Lab 5 - Remove firewall rule
```bash
sudo ufw status numbered
sudo ufw delete <rule_number>
```

### Lab 6 - Allow HTTPS traffic
```bash
sudo ufw allow 443
sudo ufw status
```

### Lab 7 - Allow SSH only from specific IP
```bash
sudo ufw allow from 192.168.1.50 to any port 22
```

### Lab 8 - Reset firewall configuration
```bash
sudo ufw reset
```


---

## Troubleshooting Scenarios 

### SSH Connection Fails 
```bash
systemctl status ssh		# Check SSH service
ss -tuln 			# Check listening ports
sudo ufw status 		# Check firewall rules
sudo ufw allow 22 		# Fix: open SSH Port
```


### Website Not Accessible
```bash
systemctl status apache2 	# Check Web service
ss -tuln			# Check listening ports
sudo ufw status			# Check firewall 
sudo ufw allow 80		# Fix: open HTTP port


### Port Blocked by Firewall
```bash
sudo ufw status numbered 		# Check rules
sudo ufw delete <rule_number>		# Delete blocking rule


---


### Skills Gained 

- Configuring Linux firewall
- Opening and closing ports
- Restricting service access by IP
- Inspecting firewall rules
- Troubleshooting blocked services
- Basic iptables inspection


---


## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
