# D9 - Ansible (Configuration Management)


## What is Ansible?
Anisible is an open-source automation tool used to configure, manage, and deploy software on multiple servers simultaneously. It is agentless - it uses SSH to connect to target servers, so nothing needs to be installed on the servers being managed, Playbooks are written in YAML, the same format used in GitHub Actions (D2)


## Why Ansible?
- **Agentless** - no software to install on target servers, just SSH
- **Simple YAML syntax** - easy to read and write compared to tools like Puppet or Chef
- **Idempotent** - running the same playbook twice causes no harm, skips already-done tasks
- **Scalable** - manage 1 server or 1000 servers with the exact same playbook
- **Standard DevOps tool** - widely used in Europe/Denmark job listings alongside Terraform

## Key Concepts

| Term | Meaning |
|------|---------|
| Control Node | The machine where Ansible is installed and playbooks are run from |
| Managed Node | The target server(s) Ansible connects to and configures via SSH |
| Inventory | A file listing target servers with IP, user, and key details |
| Playbook | A YAML file describing what tasks to run on the target servers |
| Task | A single action in a playbook — install a package, start a service, etc. |
| Module | Built-in Ansible units of work — e.g. package, service, ping |
| Idempotent | Running the same playbook twice does not break anything — safe to re-run |


## Core Workflow
```bash
# Test connectivity to target servers
ansible -i inventory webservers -m ping

# Run the playbook
ansible-playbook -i inventory playbook.yml

# Run with verbose output for debugging
ansible-playbook -i inventory playbook.yml -v
```

## Inventory File
Lists target servers grouped by labels. Each entry includes the IP, SSH user, and private key path.
```
[webservers]
13.201.60.215 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/d9-ansible-key
```

## Playbook Structure
A playbook is a YAML file with one or more plays. Each play targets a server group and runs a list of tasks.
```yaml
---
- name: My first Ansible playbook
  hosts: webservers
  become: yes

  tasks:
    - name: Install nginx
      ansible.builtin.package:
        name: nginx
        state: present

    - name: Start nginx service
      ansible.builtin.service:
        name: nginx
        state: started
```
- **become: yes** - run tasks with sudo privileges on the target server
- **state: present** - install if not already installed (idempotent)
- **state: started** - start the service if not already running

## SSH Key Setup
Keys were generated directly on the Ubuntu VM (control node) so they never needed to be copied between machines.
```bash
# Generate key pair on the control node
ssh-keygen -t rsa -b 2048 -f ~/.ssh/d9-ansible-key

# View public key - safe to share, import into AWS
cat ~/.ssh/d9-ansible-key.pub

# Test SSH manually before running Ansible
ssh-i ~/.ssh/d9-ansible-key ec2-user@<server_ip>
```

## Lab - Install and Start Nginx on EC2

**Goal:** Use Ansible to automatically install and start Nginx on an EC2 instance without SSHing in manually.

### Step 1 - Install Ansible
```bash 
sudo apt update
sudo apt install ansible -y
ansible --version
```

### Step 2 - Generate SSH Key and Import to AWS
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/d9-absible-key
cat ~/.ssh/d9-ansible-key.pub
# Copy the public key output and import it in AWS EC2 -> Key Pairs -> Import Key pair
```

### Step 3 - Launch EC2 Instance
- AMI: Amazon Linux 2023
- Instance type: t3.micro
- Key pair: d9-ansible-key (imported above)
- Security group: allow SSH inbound (port 22) + All traffic outbound


### Step 4 - Create Inventory File
```bash
mkdir ~/d9-ansible && cd ~/d9-ansible
nano inventory
```
```
[webservers]
<ec2-public-ip> ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/d9-ansible-key
```

### Step 5 - Test Connectivity
```bash
ansible -i inventory webservers -m ping
```
Expected output: 
```
<ec2-ip> | SUCCESS => { "ping": "pong"}
```

### Step 6 - Write and Run the Playbook
```bash
nano playbook.yml
```
```yaml
---
- name: My first Ansible playbook
  hosts: webservers
  become: yes

  tasks: 
    - name: Install nginx
      ansible.builtin.package:
        name: nginx
        state: present
 
    - name: Start nginx service
      ansible.builtin.service:
        name: nginx
        state: Started
```
```bash
ansible-playbook -i inventory playbook.yml -v
```


## Result
```
PLAY RECAP
13.201.60.215 : ok=3  changed=2  unreachable=0  failed=0  skipped=0
```
Nginx was installed and started on the EC2 instance automatically - without a single manual SSH command.


## Troubleshooting Encountered
- **Playbook stuck on Gathering Facts** - EC2 security group had no outbound rule, so the server could not reach the internet to download packages 
- **Fix** - added All traffic outbound rule (0.0.0.0) to the security group. Playbook completed successfully after
- **Private Key security lesson** - accidentally exposed private key in chat. Immediately deleted the key pair in AWS and generated a fresh one on the control node. Private keys must never be shared or pasted anywhere


## Skills Gained
- understanding Ansible architecture and how it works agentlessly over SSH
- Installing and configuring Ansible on a Linux control node
- Generating SSH key pairs on the control node and importing public keys to AWS
- Writing inventory files to define and group target servers
- Writing Ansible playbooks in YAML to automate server configuration
- Using built-in modules - ping, package, service
- Running playbooks and interpreting PLAY RECAP output
- Troubleshooting EC2 security group outbound rules
- Understanding idempotency in practice


## Important Rules
- Never share or paste a private key anywhere
- Always generate SSH keys on the machine that will use them
- Always terminate EC2 instances after lab sessions to avoid charges
- Security groups need both inbound (SSH port 22) AND outbound rules for Ansible to work
- Always run `ansible -m ping` first to verify to verify connectivity before running playbooks

## Environment Used

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Control Node | Ubuntu 24.04 VM on VirtualBox |
| Ansible Version | 2.16.3 |
| Managed Node | Amazon Linux 2023 on EC2 (t3.micro) |
| AWS Region | ap-south-1 (Mumbai) |
| GitHub | github.com/sachin-linux/linux-admin-homelab |

