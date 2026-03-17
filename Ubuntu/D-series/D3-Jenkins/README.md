# D3 - Jenkins

## Objective

Learn how to install, configure, and use Jenkins as a CI/CD automation server.

This module demonstrates:
- Understanding why Jenkins exists
- Installing Jenkins on Ubuntu
- Creating freestyle jobs
- Connecting Jenkins to GitHub
- Configuring webhooks for automatic build triggers
- Real-world troubleshooting during setup

## What is Jenkins
Jenkins is an open-source automation server that automates everything that happens after a developer pushes code to GitHub - pulling code, running tests, building and deploying the app. No human needed.

## The Problem Before Jenkins
Developers pushed code to GitHub manually. Then someone had to SSH into the server, pull the latest code, run tests and deploy - all manually. With 10 developers pushing code multiple times a day, this was slow, error-prone and unsustainable.

## Jenkins Architecture
```
Developer -> git push -> GitHub -> Webhook -> ngrok -> Jenkins -> Pull code -> Run commands -> SUCCESS/FAILURE
```

## Key Concepts
| Term | Meaning |
|------|---------|
| Job | A task Jenkins runs (build/test/deploy) |
| Pipeline | Full automated workflow |
| Freestyle Job | Simple job configured via UI |
| Webhook | GitHub notifies Jenkins instantly on push |
| ngrok | Exposes local Jenkins to the internet |
| Workspace | /var/lib/jenkins/workspace/ |
| Jenkins user | Dedicated system user for security |

## What is a Webhook
A doorbell. When a developer pushes code, GitHub instantly notifies Jenkins. Jenkins doesn't need to keep checking GitHub - GitHub tells Jenkins the moment something happens.

## What is ngrok 
Jenkins runs on a private IP that GitHub cannot reach from the internet. ngrok gives Jenkins a public URL so GitHub can send webhook notifications to it.

## Installation Commands
```bash 
# Update package list
sudo apt update

# Install Java 17 (Jenkins dependency)
sudo apt install openjdk-17-jdk -y

# Verify Java
java --version

## Add Jenkins GPG key
sudo gpg --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
sudo gpg --armor --export 7198F4B714ABFC68 | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

## Add Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

## Update and install Jenkins
sudo apt update
sudo apt install jenkins -y

## Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

## Open port 8080 in firewall
sudo ufw allow 8080
```

## Accessing Jenkins
Open browser and go to:
```
http://localhost:8080        # from same machine
http://Device IP:8080   # from host machine (Kali)
```

## Install Setup
- Jenkins generates a one-time admin password on first boot
- Found in logs: sudo journalctl -u jenkins
- Or at: /var/lib/jenkins/secrets/initialAdminPassword
- Enter password on browser -> Install suggested plugins -> Create admin user

## Jobs Created
- `my-first-job` - first freestyle job running echo, date, whoami 
- `jenkins-github-job` - connected to GitHub, auto-triggered on push

## Webhook Setup Flow
1. Start ngrok: ngrok http 8080
2. Copy public URL (e.g. https://xyz.ngrok-free.dev)
3. Add webhook in GitHub repo settings -> Payload URL: https://xyz.ngrok-free.dev/github-webhook
4. In Jenkins job -> Configure -> Triggers -> enable "GitHub hook trigger for GITscm polling"
5. update Jenkins URL: Manage Jenkins -> Configure -> Jenkins URL -> set to ngrok URL

## Troubleshooting Done in This Lab
| Problem | Fix |
|---------|-----|
| GPG key verification failed | Used --armor flag when exporting key |
| Jenkins UI not loading | Added -Dhudson.model.UpdateCenter.never=true to JAVA_ARGS |
| Port 8080 not accessible | sudo ufw allow 8080 |
| Webhook returning 404 | Updated Jenkins URL to ngrok public URL |
| git push authentication failed | Used GitHub Personal Access Token instead of password |

## Key Observations
- Jenkins runs as dedicated system user `jenkins` for security
- Jenkins workspace: /var/lib/jenkins/workspace/
- Jenkins needs java to run - it is built in java
- Freestyle jobs are UI-based, Pipelines are code-based (Jenkinsfile)
- ngrok URL changes every session on free plan

## Skills Learned 
- Installing and configuring Jenkins on Ubuntu
- Creating and running freestyle jobs
- Connecting Jenkins to a GitHub repository
- Configuring webhooks for automatic build triggers
- Using ngrok to expose local server to internet
- Real-world troubleshooting: GPG keys, firewall, authentication

## Environment used
Ubuntu Linux
Virtualbox
Jenkins 2.541.2 
Java 17
ngrok
GitHub
