# U10 - Bash Scripting

## Objective
introduce Bash scripting for Linux automation.
Bash scripts allow administrators to automate repetitive tasks such as system monitoring, backups, service checks, and log inspection.


---


## Topics Covered
- Bash shell basics 
- Script structures
- Shebang (`#!/bin/bash`)
- Creating and running scripts
- File permissions for scripts
- Variables in Bash
- User input using `read`
- Conditional statements (`if / else`)
- Loops (`for / while`)
- Basic automation scripts


---


## Key Commands 
| Command | Purpose |
|---------|---------|
| `nano` | Create/edit script file |
| `chmod +x` | Make script executable |
| `./script.sh` | Run script |
| `echo` | Print output |
| `whoami` | Show current user |
| `date` | Show current date/time |
| `uptime` | Show system uptime |
| `df -h` | Show disk usage |
| `systemctl` | Manage services |


---

## Script Structure
```bash
#!/bin/bash
# This is a comment 
echo "Hello Linux"
```


## Labs Performed

### Lab 1 - Create first Bash script
```bash
nano hello.sh
```
```bash
#!/bin/bash
echo "Hello Linux"
```
```bash
chmod +x hello.sh
./hello.sh
```

---

### Lab 2 - System information script
```bash
nano systeminfo.sh
```
```bash
#!/bin/bash
echo "User:"; whoami
echo "Date:"; date
echo "System uptime:"; uptime
```

---


### Lab 3 - Variables in Bash
```bash
nano variable.sh
```
```bash
#!/bin/bash
name="Sachin"
echo "Welcome $name"


---


### Lab 4 - User input script
```bash
nano input.sh
```
```bash
#!/bin/bash
echo "Enter username"
read username
echo "User entered: $username"
```

---


### Lab 5 - If condition script
```bash
nano checknumber.sh
```
```bash
#!/bin/bash
echo "Enter a number:"
read num
if [ $num -gt 50 ]
then
  echo "Number greater than 50"
else
echo "Number 50 or smaller"
fi 
```


---


### Lab 6 - Loop script
```bash
nano loop.sh
```
```bash
#!/bin/bash
for i in 1 2 3 4 5
do 
  echo "Loop $i"
done
```


---


### Lab 7 - Disk monitoring script
```bash
nano diskcheck.sh
```
```bash
#!/bin/bash
echo "Disk usage report"
df -h
```


---


### Lab 8 - Service check script
```bash
nano sshcheck.sh
```
```bash
#!/bin/bash
systemctl status ssh
```

---


## Troubleshooting
| Issue | Fix |
|-------|-----|
| Script not executable | `chmod +x script.sh` |
| Script not found | Run as `./script.sh` |
| Wrong interpreter | Ensure first line is `#!/bin/bash` |


---


##Skills gained 

- Writing Bash scripts
- Automating linux tasks
- Using variables in scripts
- Handling user input
- Using conditions and loops
- Creating simple admin automation tools


---


## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
