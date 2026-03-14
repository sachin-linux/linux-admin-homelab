# D4 – Docker Fundamentals

## What is Docker?

Docker is a containerization platform used to package applications with all their dependencies into containers. Instead of installing software directly on a server, we run it inside containers — ensuring the same environment everywhere.

**Traditional vs Docker Deployment:**
```
Traditional:          Docker:
Application           Application
Dependencies          Dependencies
Operating System      Container
Hardware              Docker Engine
                      Operating System
                      Hardware
```

**Benefits:**
- Same enviroment everywhere
- Fast deployment 
- Lightweight
- Easy scaling

---

## Docker 

| Component | Description |
|---|---|
| Docker Engine | Core service running containers |
| Docker Image | Blueprint of a container (read-only) |
| Docker Container | Running instance of an image |
| Dockerfile | Script to build images |
| Docker Hub | Public image registry |
| Component | Description |
|---|---|
| Docker Engine | Core service running containers |
| Docker Image | Blueprint of a container (read-only) |
| Docker Container | Running instance of an image |
| Dockerfile | Script to build images |
| Docker Hub | Public image registry |

---

## Installation (Ubuntu 24.04 Noble)

```bash
# Add Docker's GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker/asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker/asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed -by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
   noble stable" | sudo tee /etc/apt/source.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable service
sudo systemctl start docker
sudo systmctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker run hello-world
```

---

# Lab 1 - Basic Docker Commands

```bash
# Check Docker service
systemctl status docker

# Pull an image
docker pull nginx

# Run container in foreground
docker run nginx

# List running containers
docker ps

# List all containers including stopped
docker ps -a

# Stop a container
docker rm <container-id>

# Remove an image
docker rmi nginx

# Bulk stop and remove all containers
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

---

## Lab 2 - Interactive Container + Dockerfile

```bash
# Run Ubuntu Container interactively
docker run -it ubuntu bash

# Inside container
ls
pwd
cat /etc/os-release
exit
```

**First Dockerfile:**
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
CMD ["echo", "MY first Docker image!"]
```

```bash
# Build image from Dockerfile
docker build -t myapp:v1 .

# Run your own image
docker run myapp:v1

# Verify image exists
docker images
```

**Key Dockerfile Instructions:**

| Instruction | Meaning |
|---|---|
| `FROM` | Base image to start from |
| `RUN` | Command to run during build |
| `CMD` | Command to run when container starts |

---

## Lab 3 - Port Mapping

Containers are isolated - port mapping connects host port to container port so you can access services running inside containers.

```
Browser -> Host Port 80808 -> Container Port 80
```

```bash
# Run nginx with port mapping
docker run -d -p 8080:80 nginx

# Test from terminal
curl http://localhost:8080

## Run second nginx on different port
docker run -d -p 8081:80 nginx

# Check both running
docker ps

# Clean up 
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

---

## Lab 4 - Volumes (Persistent Storage)

Containers are temporary - when removed all data inside it lost. Volumes store data outside the container on the host machine so it persist even after container deletion.

```bash
# Create a volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect mydata

# Run container with volume mounted
docker run -it -v mydata:/app ubuntu bash

# Inside container - create a file
echo "Hello from container" > /app/testfile.txt
cat /app/testfile.txt
exit

# Remove container
docker rm $(docker ps -aq)

# Run NEW container with same volume - data still exists
docker run -it -v mydata:/app ubuntu bash
cat /app/testfile.txt
exit

# Remove volume
docker volume rm mydata
```

---

## Lab 5 - Environment Variables 

Never hardcode sensitive info like passwords or API keys in your app. Pass them as environment variables at runtime using `-e`.

``bash
# Pass single environment variable 
docker run -it -e MY_NAME=name ubuntu bash
echo $MY_NAME
exit

# Pass multiple environment variables 
docker run -it -e MY_NAME=name -e MY_CITY=city ubuntu bash
echo $MY_NAME
echo $MY_CITY
exit

# Check all env variables inside container
env

# Real world example - MySQL with env variables
docker run -d \
  -e MYSQL_ROOT_PASSWORD=mypassword \ 
  -e MYSQL_DATABASE=mydb \
  mysql:8.0

# Jump inside running container
docker exec -it $(docker ps -q) bash
env

# Clean up
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker rmi mysql:8.0
```

---

## Key Concepts Summary
| Concept | Command | Description |
|---|---|---|
| Pull image | `docker pull <image>` | Download image from Docker Hub |
| Run container | `docker run <image>` | Create and start a container |
| Background mode | `docker run -d` | Run container in background |
| Interactive mode | `docker run -it` | Get shell inside container |
| Port mapping | `docker run -p host:container` | Map host port to container port |
| Volume | `docker run -v name:/path` | Mount persistent storage |
| Env variable | `docker run -e KEY=VALUE` | Pass environment variable |
| List images | `docker images` | Show all local images |
| List containers | `docker ps -a` | Show all containers |
| Stop container | `docker stop <id>` | Stop a running container |
| Remove container | `docker rm <id>` | Delete a stopped container |
| Remove image | `docker rmi <image>` | Delete an image |

---

## Environment Used
- Kali linux host
- GitHub Actions cloud runner
- Ubuntu Latest (GitHub hosted)
- python 3.12.3
- GitHub CLI/Web UI
