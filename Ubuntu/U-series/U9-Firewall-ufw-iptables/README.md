# U9 - FIrewall (UFW / IPTABLES)

## Objective

This module focuses on configuring and managing firewalls in Linux systems.

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
- Basic IPTables inspection
- Opening and closing ports
- Restricting access by IP address 

--- 

## Commands Learned

ufw status
ufw enable
ufw disable
ufw allow
ufw deny
ufw delete
ufw reset
ufw status numbered
ufw allow from <ip>
ufw allow <port>
ufw allow <port-range>
iptables -L
ss - tuln

---

## Labs Performed

Lab 1 - Check firewall status

Command:
sudo ufw status

---

Lab 2 - Enable firewall

Command: 
sudo ufw enable 

Verify: 
sudo ufw status 

---

Lab 3 - Allow SSH access

Command:
sudo ufw allow 22

Verify:
sudo ufw status

---

Lab 4 - Block HTTP traffic

Command:
sudo ufw deny 80 

Verify:
sudo ufw status numbered

---

Lab 5 - Remove firewall rule

Check rules:
sudo ufw status numbered

Delete rule:
sudo ufw delete <rule_number>

---

Lab 6 - Allow HTTPS traffic

Command:
sudo ufw allow 443

Verify:
sudo ufw status

---

Lab 7 - Allow SSH only from specific IP

Command:
sudo ufw allow from 192.168.1.50 to any port 22

--- 

Lab 8 - Reset firewall configuration

Command:
sudo ufw reset

---

## Troubleshooting Scenarios 

### SSH Connection Fails 

Check SSH service:
systemctl status ssh

Check listening ports:
ss -tuln

Check firewall rules:
sudo ufw status

Fix:
sudo ufw allow 22

---

### Website Not Accessible

Check web service:
systemctl status apache2

Check listening ports:
ss -tuln

Check firewall:
sudo ufw status

Fix:
sudo ufw allow 80

---

### Port Blocked by Firewall

Check rules:
sudo ufw status numbered

Delete blocking rule: 
sudo ufw delete <rule_number>

---

### Skills Gained 

- Configuring Linux firewall
- Opening and closing ports
- Restricting service access
- Inspecting firewall rules
- Troubleshooting blocked services
- Basic IPTables inspection


