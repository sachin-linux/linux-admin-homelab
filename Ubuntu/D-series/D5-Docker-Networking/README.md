# D5 - Docker Networking

## Objective
Learn how Docker networking works and how containers communicate with each other, the host machine, and external services

This module demonstrates:
* understand default Docker networks
* Creating custom docker networks
* Container-to-container communication using Docker DNS
* Port mapping from host to container
* Inspecting network cofiguration 

---

## What is Docker Networking

Docker networking allows containers to communicate with:
* The host machine
* Other containers
* The internet
* External services (databases, APIs)

Without networking:
* Containers would be fully isolated
* No web access
* No communication between services

```
[User Browser]
      │
      ▼
[NGINX Container]
      │
      ▼
[App Container]
      │
      ▼
[Database Container]
```

All these containers communicate using Docker networks.

--- 

## Default Docker Networks

Run this command to see default networks:

```bash 
docker network ls
```

Expected output:

```

NETWORK ID     NAME      DRIVER    SCOPE
xxxxxx         bridge    bridge    local
xxxxxx         host      host      local
xxxxxx         none      null      local
```

### Bridge Network (Default)
* Containers are automatically connected to this network
* Containers communicate using IP addresses
* IP addresses can change on restart - not reliable for production

### Host Network
* Container shares the host machine's network directly
* No port mapping required
* Less isolation - not recommended for production

### None Network
* No networking at all 
* Used for high security - not recommended for production

---

## Custom Docker Networks (Most Important)

DevOps engineers almost always create custom networks instead of using the default bridge.

**why custom networks?**

On the default bridge, containers talk by IP address. IPs change every time a container restarts. If your app has a database IP hardcoded and the database restarts with a new IP - your app breaks.

On a custom network, Docker's built-in DNS resolves containers by **name**, not IP. Your app just says `connect to db` and Docker always finds it - regardless of IP changes.

---

## Common Docker Networking Commands

View all networks:
```bash
docker network ls
```

Inspect a network:
```bash
docker network inspect bridge
```

Create a custom network:
```bash 
docker network create mynetwork
```

Run container on custom network:
```bash
docker run -dit --name container1 --network mynetwork nginx
```

Port mapping (host -> container):
```bash 
docker run -d -p 8080:80 nginx
```

Get container IP address:
``bash
docker inspect -f '{{range.NetworkSettings}}{{.IPAddress}}{{end}}' container1

Remove a network:
```bash
docker network rm mynetwork
```

---

## Lab Exercise

### Step 1 - View Default Networks

```bash
docker network ls
```

### Step 2 - Inspect Bridge Network

```bash
docker network inspect bridge
```

Note the subnet and gateway. Containers field will be empty.

### Step 3 - Run a Container and Watch It join Bridge

```bash
docker run -dit --name testbox ubuntu
docker network inspect bridge
```

You will now see testbox listed under Containers with an assigned IP (172.17.0.2).

## Step 4 - Clean Up and Create Custom Network

```bash
docker stop testbox
docker rm testbox
docker network create mynetwork
docker network ls
```

You will see mynetwork listed with bridge driver.

### Step 5 - Run Two Containers on Custom Network

```bash
docker run -dit --name container1 --network mynetwork nginx
docker run -dit --naem containert2 --network mynetwork ubuntu
docker ps
```

### Step 6 - Test Contaienr-to-Container Communication (Docker DNS)

Enter container2:

```bash
docker exec -it container2 bash
```

Install ping: 

```bash 
apt update -y && apt install iputils-ping -y
```

Ping container1 by name:

```bash
ping container1
```

Expected output:

```
PING container (172.18.0.2) 56(84) bytes of data.
64 bytes from container1.mynetwork (172.18.0.2): icmp_seq=1 ttl=64 time=0.191ms
```

This works because Docker DNS resolves container names automatically on custom networks.

Exit container2:

```bash
exit
```

### Step 7 - Port Mapping

Run nginx with port mapping:

```bash
docker run -d -name webserver -p 8080:80 nginx
```

Test from host:

```bash
curt http://localhost:8080
```

Expected output:

```
Welcome to nginx!
```

Host port 8080 is forwarded to container port 80.

### Step 8 - Cleanup

```bash
docker stop container1 container2 webserver
docker rm container1 container2 webserver
docker network rm mynetwork
docker ps
docker network ls
```

Everything should be back to baseline - no containers, 3 default networks only.

---

## Expected Results

* Default bridge network assigns IPs automatically but no DNS
* Custom networks enable DNS - containers resolve each other by name
* Port mapping exposes container services to the host 
* Cleanup restores system to clean state

---

## Skills Learned

* Inspecting default Docker networks (bridge, host, none)
* Creating and managing custom Docker networks
* Container-to-container communication using Docker DNS
* Port mapping from host machine to container
* Network inspection and cleanup

THese networking skills are critical in real DevOps deployments where multiple containers (web, app, database) need to communicate securly and reliably.

---

## Environment Used

Ubuntu Linux
VirtualBox
Docker Engine
Linux CLI tools
