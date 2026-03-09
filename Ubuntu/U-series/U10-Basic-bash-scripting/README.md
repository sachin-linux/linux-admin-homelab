# U10 - Bash Scripting

## Objective

This module introduces Bash scripting for Linux automation.

Bash scripts allow administrators to automate repetitive tasks such as system monitoring, backups, service checks, and log inspection.

---

## Topics Covered

- Bash shell basics 
- Script structures
- Shebang (#!/bin/bash)
- Creating and running scripts
- File permissions for scripts
- Variable in Bash
- User input using read
- Conditional statements (if / else)
- Loops (for / while)
- Basic automation scripts

---

## Commands and Concepts
 
- nano 
- chmod +x
- ./script.sh
- echo
- whoami
- date
- uptime
- df -h
- systemctl
- if
- else
- for
- while

---

## Labs Performed

Lab 1 - Create first Bash script

Create script:

nano hello.sh

Script:

#!/bin/bash
echo "Hello Linux"

Run

chmod +x hello.sh
./hello.sh

---

Lab 2 - System information script

Create:

nano systeminfo.sh

Script:

#!/bin/bash

echo "User:"
whoami

echo "Date":
date

echo "System uptime:"
uptime

---

Lab 3 - Variables in Bash

Create"

nano variable.sh

Script:

#!/bin/bash

name="Sachin"
echo "Welcome $name"

---

Lab 4 - User input script

Create"

nano input.sh

Script:

#!/bin/bash

echo "Enter username"
read username

echo "User entered: $username"

---

Lab 5 - If condition script

Create:

nano checknumber.sh

#!/bin/bash

echo "enter number"
read num

if [ $num -gt 50 ]
then
echo "Number greater than 50"
else
echo "Number 50 or smaller"
fi 

---

Lab 6 - Loop script

Create:

nano loop.sh

Script:

#!/bin/bash

for i in 1 2 3 4 5
do 
echo "Loop $i"
done

---

Lab 7 - Disk monitoring script

Create:

nano diskcheck.sh

Script:

#!/bin/bash

echo "Disk usage report"
df -h

---

Lab 8 - Service check script

Create:

nano sshcheck.sh

Script:

#!/bin/bash

systemctl status ssh

---

## Troubleshooting

Script not executable:

chmod +x script.sh

Script not found:

./script.sh

Wrong interpreter:

Ensure first line contains:

#!/bin/bash

---

##Skills gained 

- Writing Bash scripts
- Automating linux tasks
- Using variables in scripts
- Handling user input
- Using conditions and loops
- Creating simple admin automation tools

---
