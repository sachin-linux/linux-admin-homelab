# P2 - Networking for DevOps

## What is Netwiorking for DevOps?
Networking for DevOps is the practical understanding of how data travels between machines, how services expose themselves on ports, how firewalls control access, and how DNS resolves names to IPs. It is the foundation of diagnosing connnectivity issues in any real infrastructure environment.


## Why It Matters?
- **Troubleshooting** - When something is unreachable knwoledge tells you exactly which layer to look at
- **Security** - Understanding open ports and firewall rules is essential to keeping servers safe
- **Infrastructure** - Every cloud server, container, and deployment pipelines depends on networking working correctly
- **Interview relevances** - Port inspection, firewall rules, and DNS troubleshooting are standard Junior DevOps/Linux Admin interview topics


## Key Concepts

| Term | Meaning |
|------|---------|
| IP Address | Unique address for a device on a network (e.g. 192.168.0.101) |
| CIDR / Subnet | /24 means first 24 bits are the network — devices sharing this can talk directly |
| DHCP | Router automatically assigns IP addresses — changes on reassignment |
| Static IP | Manually configured IP — never changes — used for servers |
| Default Gateway | The router your machine sends traffic to when it doesn't know the destination |
| TCP | Reliable, ordered protocol — used when data loss is unacceptable (SSH, HTTP, databases) |
| UDP | Fast, fire-and-forget protocol — used when speed matters more (DNS, streaming) |
| Port | Room number inside a server — OS uses it to route traffic to the right application |
| ss | Socket statistics tool — shows what ports are listening and which process owns them |
| ufw | Uncomplicated Firewall — simplified interface to manage iptables rules on Ubuntu |
| DNS | Translates domain names (google.com) into IP addresses |
| systemd-resolved | Local DNS proxy on Ubuntu — sits between apps and the upstream DNS server |
| dig | DNS lookup tool — shows full response including server used and query time |
| Orphaned firewall rule | A ufw ALLOW rule with no service listening behind it — a security risk |


## Core Commands 

```bash
# Interfaces and routing
ip addr show				# Show interfaces and IP addresses
ip route show				# Show routing table and default gateway

# Ports
sudo ss -tulnp 				# All listening TCP sockets with process names
sudo ss -tulnp | grep LISTEN		# Filter to only listening sockets
sudo ss -tulnp | grep <port>		# Check a specific port

# Firewall
sudo ufw status verbose			# Show firewall status and all rules
sudo ufw status numbered 		# Show rules with numbers for easy deletion
sudo ufw allow 8082/tcp			# Allow a port
sudo ufw deny 8080/tcp			# Deny a port
sudo ufw delete <number>		# Delete rule by number
sudo ufw enable				# Enable the firewall

# DNS
dig google.com				# Full DNS lookup with timing and server info
dig +trace google.com			# Trace full resolution path from root servers
nslookup google.com			# Quick simple lookup
resolvectl status			# Show DNS config and upstream servers	
```

### Scenarios Practised

### Scenario 1 - Interface and Routing Inspection
**Problem:** Need to understand the VM's network setup - IP, gateway, and DNS.
**Investigate:** Ran `ip addr show` - saw VM IP 192.168.0.101/24 assigned via DHCP. Ran `ip route show` - saw default gateway 192.168.0.1 and explicit routes 1.1.1.1 and 8.8.8.8 pushed by the DHCP server.
**Fix:** No fix needed - observation exercise.
**Key lesson:** `proto dhcp` in the route table means the router assigned this IP automatically. In production servers you'd use a static IP so it never changes - because if a server's IP changes, everything pointing to it breaks.

### Scenario 2 - Port Inspection
**Problem:** Need to identify what services are running and listening on the VM.
**Investigate:** Ran `sudo ss -tulnp | grep LISTEN` - identified SSH on 2222, Prometheus on 9090, Node Exporter on 9100, Grafana on 3000, and web services on 80/8080/8081. All services from previous D-series modules still running
**Fix:** No fix needed - observation exercise.
**Key lesson:** `ss -tulnp` without sudo hides process names. Always use sudo to see which process owns which port. If a port is missing from this list, the service is not running - check `systemctl status <service>`.

### Sceanrio 3 - Firewall Audit and Orphaned Port Cleanup
**Problem:** While auditing ufw rules, found three ALLOW rules for ports 65534, 60000, and 6000 with nothing behind them.
**Investigate:** Ran `sudo ss -tulnp | grep -E '65534|60000|6000'` - no output. Checked ufw logs and systemd config - nothing referencing these ports. Confirmed they were orphaned rules from old experiments.
**Fix:** 
```bash
sudo ufw delete <rule number>	# repeated for each orphaned rule and duplicates
```
Also removed duplicate rules for ports 22 and 2222 (both plain and /tcp versions existed).
**Key lessons:** Every unexplained open port is a potential attack surface. Periodically audit your firewall rules. If you cannot answer "what is this port for?" - it should not be open. 

### Scenario 4 - DNS Inspection
**Problem:** Need to understand how DNS resolution works on the VM and verify the upstream servers.
**Investigate:** Ran `dig google.com` - got answer 142.250.205.110 in 64ms. SERVER line showed 127.0.0.53 - not 1.1.1.1 directly. Ran `resolvectl status` - confirmed upstream DNS servers are 1.1.1.1 and 8.8.8.8\

### Scenario 5 - Capstone: Diagnose and Fix Unreachable Service
**Problem:** Developer reports app on port 8082 is unreachable - getting connection refused.
**Investigate step by step:**
```bash
ss -tulnp | grep 8082		# Confirmed python3 listening on 8082 - service is up
curl http://localhost:8082	# worked locally - network layer fine within the machine
sudo ufw status numbered	# port 8082 not in allowed rules - firewall blocking it 
```
**Fix:** 
```bash
sudo ufw allow 8082/tcp
curl http://localhost:8082 	# confirmed reachable
```
**Key lesson:** A service can be running and listening but still unreachable externally if the firewall blocks it. The troubleshooting flow is always: is the process running? -> is it listening? -> can I reach it locally? -> is the firewall allowing it?

## Golden Rules
- **Never open a port without knowing why** - every open port is a potential attack surface
- **Always allow SSH before enabling ufw** enable ufw without allowing SSH and you lock yourself out permanently
- **Use `sudo` with ss** - without it, process names are hidden and the output is incomplete
- **Audit firewall rules regularly** - orphaned rules accumulate silently over time
- **When DNS breaks, check layers** - ping IP first, then ping domain - this isolates DNS vs routing instantly
- **Static IP for servers** - DHCP is fine for homelab but in production a server's IP must never change

## Skills Gained
- Reading network interfaces, IP addresses, and routing tables in Linuxx
- Identifying listening services by port and process name using ss
- Auditing ufw firewall rules and safely removing orphaned and duplicate entries
- Understanding DNS resolution flow from app -> systemd-resolved -> upstream server
- Using dig and resolvectl to inspect DNS behaviour and confirm upstream configuration
- Diagnosing connectivity issues using a layered approach: process -> local -> firewall
- Recognising the difference between a service problem and a firewall problem

## Environment Used 

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Remote Repo | github.com/sachin-linux/linux-admin-homelab |
| Key Tools | ip, ss, ufw, dig, resolvectl, curl, ping |
