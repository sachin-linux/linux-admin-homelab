# D8 - Terraform (Infrastructure as Code)

## What is Terraform?
Terraform is an Infrastructure as Code (IaC) tool by HashiCorp. Instead of manually clicking through cloud consoles to create servers and networks, you define your infrastructure in `.tf` files and Terraform builds it automatically. It is cloud-agnostic — works with AWS, GCP, Azure, and more.

---

## Why Terraform?
- Infrastructure is version-controlled, reviewable, and repeatable
- Same config can deploy to multiple regions or environments
- Detects drift — if someone manually changes a resource, Terraform catches it
- Standard tool in DevOps job listings, especially in Europe/Denmark

---

## Core Workflow
```bash
terraform init      # Download provider plugins
terraform plan      # Preview changes without touching anything
terraform apply     # Build the infrastructure
terraform destroy   # Tear everything down
```

---

## Key Files
| File | Purpose |
|------|---------|
| `main.tf` | Infrastructure definition |
| `terraform.tfstate` | Terraform's memory of what it built |
| `.terraform.lock.hcl` | Locks provider versions for consistency |

---

## HCL Syntax (HashiCorp Configuration Language)

### Provider
```hcl
provider "aws" {
  region = "ap-south-1"
}
```

### Resource
```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
}
```
Format: `resource "resource_type" "local_label" { }`
The second name (`my_server`) is a local reference label — not the name on AWS.

### Variable
```hcl
variable "instance_type" {
  default = "t3.micro"
}
```
Used as `var.instance_type` inside resources.

### Output
```hcl
output "server_ip" {
  value = aws_instance.my_server.public_ip
}
```
Prints useful info (like public IP) after `terraform apply`.

---

## AWS Concepts
| Term | Meaning |
|------|---------|
| EC2 | Virtual server rented from AWS, running in their data center |
| AMI | OS template used to boot the EC2 instance (e.g. Ubuntu 24.04) |
| Security Group | Firewall — controls inbound/outbound traffic to EC2 |
| Key Pair | SSH authentication — public key on server, private key on your machine |
| IAM User | AWS identity with specific permissions — never use root for Terraform |
| Access Keys | Credentials used by Terraform/CLI to authenticate to AWS API |
| ap-south-1 | AWS Mumbai region — closest to India, Free Tier eligible |

---

## AWS Setup Done
- Created AWS Free Tier account
- Created IAM user `terraform-user` with:
  - `AmazonEC2FullAccess`
  - `AmazonVPCFullAccess`
- Generated access keys (Access Key ID + Secret Access Key)
- Configured on Ubuntu VM:
```bash
aws configure
# region: ap-south-1
# format: json
```
- Verified with:
```bash
aws sts get-caller-identity
```

---

## Installation

### Terraform
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
terraform -v
```

### AWS CLI
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y && unzip awscliv2.zip
sudo ./aws/install
aws --version
```

---

## Lab 1 — Local Provider & State
**Goal:** Learn init → plan → apply → destroy workflow without touching cloud.

```hcl
resource "local_file" "hello" {
  content  = "Hello from Terraform!"
  filename = "/home/user/terraform-labs/lab1/hello.txt"
}
```

**What was proved:**
- Terraform creates the file on `apply`
- `terraform.tfstate` records what was built
- Deleting the file manually → `terraform plan` detects drift and plans to recreate it
- `terraform apply` restores it — this is drift detection in action

---

## Lab 2 — Real EC2 Instance on AWS
**Goal:** Provision a real server on AWS using Terraform.

```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_server" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-lab2"
  }
}

output "server_ip" {
  value = aws_instance.my_server.public_ip
}
```

**Note:** Use `t3.micro` not `t2.micro` — `t2.micro` is no longer Free Tier eligible in `ap-south-1`.

**What was proved:**
- Terraform called the AWS API using IAM credentials
- EC2 instance created in Mumbai in ~13 seconds
- `terraform show` printed full instance details including public IP
- `terraform destroy` terminated the instance cleanly

---

## Lab 3 — Security Group + Key Pair + SSH
**Goal:** Make the EC2 instance accessible via SSH.

### Generate SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/lab3
```

### main.tf
```hcl
resource "aws_security_group" "ssh_access" {
  name        = "allow-ssh"
  description = "Allow SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "terraform-lab3-key"
  public_key = file("~/.ssh/lab3.pub")
}

resource "aws_instance" "my_server" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "terraform-lab3"
  }
}

output "server_ip" {
  value = aws_instance.my_server.public_ip
}
```

### SSH into the server
```bash
ssh -i ~/.ssh/lab3 ubuntu@<server_ip>
```

**What was proved:**
- Terraform created 3 resources in correct dependency order automatically
- Key pair uploaded to AWS, security group opened port 22
- SSHed into a live Ubuntu server running in AWS Mumbai
- `terraform destroy` terminated all 3 resources cleanly

---

## Important Rules
- Always run `terraform plan` before `terraform apply`
- Never delete `terraform.tfstate` manually
- Always run `terraform destroy` after lab sessions — avoid unexpected charges
- Never use root AWS account for Terraform — always IAM user with least privilege
- Log out of AWS console after every session

---

## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu 24.04 VM on VirtualBox |
| Terraform Version | v1.14.7 |
| AWS CLI Version | v2.34.13 |
| AWS Provider Version | hashicorp/aws v5.100.0 |
| AWS Region | ap-south-1 (Mumbai) |
| Instance Type | t3.micro (Free Tier eligible) |
| AMI | ami-0f58b397bc5c1f2e8 (Ubuntu 24.04) |
