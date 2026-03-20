#U1 - Linux Basic

#Objective 
Understand fundamental Linux commands and system navigation for system administration.

---

## Topics Covered

- Linux filesystem structure
- Basic shell commands
- File and directory management
- Viewing and editing files
- File permissions basics
- Process monitoring basics

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `pwd` | Print working directory |
| `ls` | List directory contents |
| `cd` | Change directory |
| `cp` | Copy files |
| `mv` | Move or rename files |
| `rm` | Remove files |
| `mkdir` | Create directory |
| `touch` | Create empty file |
| `cat` | View file contents |
| `less` | Scroll through file contents |
| `nano` | Text editor |
| `head` | View first lines of file |
| `tail` | View last lines of file |

---

## Filesystem Navigation
```bash
pwd			# Show current directory
ls -l 			# List with details
cd /var/log 		# Navigate to log directory
cd ~ 			# Go to home directory
```

---


## File Operations

###Create file 
```bash
touch file.txt
```

### copy file
```bash
cp file.txt backup.txt
```

###Move file
```bash
mv file.txt /tmp
```

###Delete file
```bash
rm file.txt
```

---


## Lab

1. Create a directory named 'linux-practice'
2. Create files inside it
3. Copy and move files
4. Remove test files

---

## Skills Gained

- Basic Linux command usage
- Filesystem navigation
- File management operation

---


## Enviroment Used 

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |	
