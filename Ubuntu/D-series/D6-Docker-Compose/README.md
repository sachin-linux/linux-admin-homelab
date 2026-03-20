# D6 - Docker Compose 

## Objective
Learn how to define and manage multi-container Docker applications using Docker Compose.


---


## Topics Covered 
- Understanding why Docker Compose exists
- Writing a `docker-compose.yml` file
- Starting and stopping a multi-container stack
- Viewing logs from all containers
- Managing services with Compose commands


---


## What is Docker Compose
Docker Compoase is a tool that lets you define and run multi-container Docker applications using a YAML file.

Instead of running multiple `docker run` commands manually, you describe your entire application stack in one file called `docker-compose.yml` and start everything with one command.


--- 


## Why Docker Compose Exists

**Without Compose**

```bash
docker network create mynetwork
docker run -d --name db --network mynetwork -e POSTGRES_PASSWORD=secret postgres
docker run -d --name app --network mynetwork -p 5000:5000 myapp
docker run -d --name db web --network mynetwork -p 8080:80 nginx
```

**Problems with this approach:**
- Easy to forget a flag
- Teammates might run commands directly
- No single source of truth
- Hard to reproduce on another server

With Compose, all of that is replaced by one clean file that everyone uses.


--- 


## Real World Use Case
Every real DevOps project uses Compose or something similar:
```
[Browser]
    │
    ▼
[Nginx Container]        ← handles incoming traffic
    │
    ▼
[App Container]          ← runs your Python/Node app
    │
    ▼
[Database Container]     ← PostgreSQL / MySQL
```
All three defined in one `docker-compose.yml`. One command starts the whole thing.


---


## Docker Compose File Structure
```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"

  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: secret
```

| Section | What it does |
|---------|-------------|
| `services` | Defines each container in the stack |
| `image` | Which Docker image to use |
| `ports` | Port mapping (host:container) |
| `environment` | Environment variables passed to container |
| `volumes` | Persistent storage |
| `networks` | Custom networks |
| `depends_on` | Start order — e.g. app starts after db |


--- 


## Key Commands
| Command | What it does |
|---------|-------------|
| `docker compose up` | Start all containers |
| `docker compose up -d` | Start in background (detached) |
| `docker compose down` | Stop and remove containers and network |
| `docker compose ps` | List running services |
| `docker compose logs` | View logs from all containers |
| `docker compose logs -f` | Follow logs live |
| `docker compose build` | Build images defined in Compose |


---


## Compose vs Manual Docker Commands
| Feature | Manual docker run | Docker Compose |
|---------|------------------|----------------|
| Multi-container setup | Multiple commands | One file |
| Reproducible | ❌ Easy to make mistakes | ✅ Same every time |
| Team friendly | ❌ Everyone runs differently | ✅ Everyone uses same file |
| Start everything | Multiple commands | `docker compose up` |
| Stop everything | Multiple commands | `docker compose down` |
| Network creation | Manual | ✅ Automatic |


--- 


## Lab Exercise 

### Step 1 - Create Working Directory
```bash
mkdir ~/docker-compose-lab
cd ~/docker-compose-lab
```

### Step 2 - Create Compose File 
```bash
nano docker-compose.yml
```
```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"

  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: secret123
```
```bash 
Cat docker-compose.yml	   # Verify file
```

### Step 3 - Start the Stack
```bash
docker compose up -d
```
Expected output:
```
✔ Network docker-compose-lab_default  Created
✔ Container docker-compose-lab-db-1   Started
✔ Container docker-compose-lab-web-1  Started
```
Note: Compose automatically creates the network - no manual `docker network create` needed.

### Step 4 - Verify Containers Are Running
```bash
docker compose ps
```

### Step 5 - Test Nginx
```bash
curl http://localhost:8080
```
Expected output:
```
Welcome to nginx!
```

### Step 6 - View Logs
```bash
docker compose logs		# View all logs
docker compise logs -f 		# Follow logs live (Ctrl+C to stop)
```

### Step 7 - Bring Everything Down
```bash
docker compose down
```
Expected output:

```
✔ Container docker-compose-lab-db-1   Removed
✔ Container docker-compose-lab-web-1  Removed
✔ Network docker-compose-lab_default  Removed
```

### Step 8 - Verify Cleanup
```bash
docker ps 
docker network ls
```
No containers running, back to 3 default networks only.


---


## Key Observations

- Compose automatically created and removed the network - no manual steps
- Container names follow the pattern" `foldername-servicename-number`
- Database port 5432 is not exposed to host - only accessible inside the network
- `docker compose logs` shows all container logs in one place
- One file,one command - entire stack up or down


---


## Skills Learned

- Writing a `docker-compose.yml` file
- Defining multiple services in one file
- Starting and stopping a full stack with single commands
- Viewing and following logs from multiple containers
- Understanding automatic network creation in compose


---


## Environment Used
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Docker Engine | Latest stable |
| Docker Compose | v2 |
| Interface | Linux CLI |
