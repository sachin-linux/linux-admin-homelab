# UB1 - Ubuntu Server Setup Lab

##Objective 
Install Ubuntu Server in VirtualBox and prepare it for remote administration.

---

##Lab Environment 

Host Machine: 
- Kali Linux

virtual Machine:
- Ubuntu Server

Hypervisor:
-VirtualBox

---

##Steps Performed

## 1. Downnload Ubuntu Server ISO

Downloaded the Ubuntu Server ISO from the official Ubuntu website.

### 2. Create Virtual Machine

Created a new VirtualBox VM with the following configuration:

- RAM: 2 GB
- CPU: 2 Cores
- Disk: 20 GB (VDI)

### 3. Install Ubuntu Server

Booted the virtual machine usine the ubuntu Server ISO and completed the installation process.

### 4. Create System USer

Created a user account during installation.

Example user:

```bash 
user 
```

### 5. Install OpenSSH Server

Enabled OpenSSH during installation to allow SSH access.

Verify SSH Serive: 

```bash
sudo systemctl status ssh
```

### 6. Check IP Address

```bash
ip addr 
```

### 7. Tesh SSH Connection

From the host machine:

```bash 
ssh user@server-ip
```

---

## Commands Used

```bash
ip addr
systemctl status ssh
ssh user@server-ip
```

## Skills Learned 

- Unbuntu Server installation
- Virtual machine setup
- SSH service verification
- Basic networking commands
- Remote administration using SSH

---

## Result 

Ubuntu Server successfully installed and configured.
SSH access verified from the host machine.
