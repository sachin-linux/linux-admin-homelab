#U8 - Networking Troubleshooting

## Objective
Diagnose and troubleshoot network issue on Linux systems.
Linux administrations must be able to quickly identify connectivity problems, DNS failures, routing issues, and serive port availability.

___


## Topics covered 

- Network interface inspections
- Ip address verification
- Connectivity testing 
- Routing table analysis
- DNS troubleshooting
- Port and service inspection
- Network path tracing
- Active connection monitoring
- Network interface statistics
- Netplan configuration inspection
- Testing remote ports


---


## Key Commands
| Command | Purpose |
|---------|---------|
| `ip addr` | Show IP addresses |
| `ip link` | Show network interfaces |
| `hostname -I` | Show system IP addresses |
| `ping` | Test connectivity |
| `ip route` | Show routing table |
| `cat /etc/resolv.conf` | Show DNS configuration |
| `nslookup` | DNS lookup |
| `ss -tuln` | Show listening ports |
| `ss -tulnp` | Show listening ports with process names |
| `ss -s` | Show network statistics |
| `traceroute` | Trace network path |
| `ip -s link` | Show interface statistics |
| `nc` | Test remote ports |
| `netplan` | Network configuration tool |

---

## Labs performed
| Lab | Task |
|-----|------|
| Lab 1 | Inspect network interfaces |
| Lab 2 | Verify system IP address |
| Lab 3 | Test network connectivity using ping |
| Lab 4 | Analyze routing table |
| Lab 5 | DNS troubleshooting |
| Lab 6 | Inspect listening ports |
| Lab 7 | Trace network path using traceroute |
| Lab 8 | Inspect active network connections |
| Lab 9 | Check interface statistics |
| Lab 10 | Inspect Netplan configuration |
| Lab 11 | Restart networking service |
| Lab 12 | Test remote service ports |


---


## Skills Gained 

- Diagnosing network connectivity issues
- Understanding routing configuration 
- Troubleshooting DNS failures
- Inspecting service ports
- Analyzing network paths
- Monitoring active connections
- Investigating network interface statistics 


---


## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
