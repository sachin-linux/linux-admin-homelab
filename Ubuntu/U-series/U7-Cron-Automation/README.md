# U7 - Cron Automation

## Objective
Automate repetitive Linux tasks using Cron.
Cron allows administrators to schedule commands or scripts to run automatically at specified times - used in production for backups, log cleanup, monitoring, and system maintenance


---

## Topics Covered
- Cron service management
- Crontab commands
- Cron syntax
- Special cron keywords
- System-wide- cron jobs
- Cron directories
- Cron logs
- Cron environment issues
- Output redirection
- Cron security
- Cron troubleshooting


---

## Cron Service
```bash
systemctl statsu cron		# Check cron status
sudo systemctl start cron 	# Start cron service
sudo systemctl enable cron	# Enable cron at boot
```

---

## Crontab Commands
| Command | Purpose |
|---------|---------|
| `crontab -e` | Edit cron jobs for current user |
| `crontab -l` | List cron jobs |
| `crontab -r` | Remove all cron jobs |
| `sudo crontab -u username -e` | Edit another user's cron jobs |

---

## Cron Syntax
```
* * * * * command
| | | | |
| | | | └── Day of week (0-7, Sunday = 0 or 7)
| | | └──── Month (1-12)
| | └────── Day of month (1-31)
| └──────── Hour (0-23)
└────────── Minute (0-59)
```

### Example
```bash
0 2 * * * /home/user/backup.sh	# Runs every day at 2:00 AM
```


---


## Common Cron Examples
```bash
* * * * * command 		# Every minute
*/5 * * * * command 		# Every 5 minutes
0 * * * * command 		# Every hour
0 0 * * * command 		# Daily at midbnight 
0 3 * * 0 command 		# Every Sunday at 3 AN
0 0 1 * * command 		# First day of every month 
```

---


## Special Cron Keywords
```bash
@reboot		# Run at system startup 
@yearly 	# Run once a year
@monthly	# Run once a month 
@weekly		# Run once a week
@daily 		# Run once a day
@hourly		# Run once a hour
```

### Example
```bash
@reboot /home/user/starup.sh 
```

---

## System-Wide Cron
```bash
# System cron config file
/etc/crontab

#Format 
minute hour day month weekday user command

# Example
0 2 * * * root /scripts/backup.sh
```

---


## Cron Directories
Linux automatically runs scripts placed in these directories:
```
/etc/cron.hourly
/etc/cron.daily
/etc/cron.weekly
/etc/cron.monthly
```

### Example
```bash
sudo cp cleanup.sh /etc/cron.daily/
```


---


## Cron Logs
```bash
grep CRON /var/log/syslog	# View cron logs
tail -f /var/log/syslog		# Monitor logs live
```


---


## Cron Environment Issue 
Cron runs with a minimal environment - always use full paths:
```bash
# Incorrect 
pyhton script.py

# Correct 
/usr/bin/pyhton3 /home/user/script.py


---


## Redirecting Cron Output
```bash
/home/user/script/sh >> /var/log/script.log 2>&1
>> appends output 
2>&1 redirects errors to same log
``` 


---


## Cron Security
```bash
/etc/cron.allow		# Only listed users can use cron
/etc/cron.deny		# Listed users cannot use cron

# Add user to cron.allow
echo user | sudo tee -a /etc/cron.allow
```

---


## Cron Troubleshooting
```bash
systemctl status cron 		# 1. Check cron service
grep CRON /var/log/syslog	# 2. Check cron logs
chmod +x script.sh		# 3. Ensure script is executable
bash script.sh			# 4. Test script manually
# 5. Always use full paths in cron commands
```

---

## Lab 1 - Basic Cron Job
```bash
nano cron-test.sh
```
```bash
#!/bin/bash
echo "Cron executed at $(date)" >> /tmp/cron-test.log
```
```bash
chmod +x cron-test.sh
crontab -e
# Add: * * * * * /home/user/cron-test.sh
cat /tmp/cron-test.log
```

---

## Lab 2 - Automated Backup
```bash
nano backup.sh
```
```bash
#!/bin/bash
SOURCE="/home/user/Documents"
DEST="/home/user/backups"
mkdir -p $DEST
tar -czf $DEST/backup-$(date +%F)/tar.gz $SOURCE
```
```bash
chmod +x backup.sh
#Add cron job: 0 2 * * * /home/user/backup.sh
```

---

## Lab 3 - Log Cleanup Automation
```bash
nano cleanup.sh
```
```bash
#!/bin/bash 
find /tmp -name "*.log" -type f -mtime +7 -delete
```
```bash
chmod +x cleanup.sh
# Add cron job 0 3 * * * * /home/user/cleanup.sh


---


## Lab 4 - Cron Troubleshooting
```bash
systemctl status cron
grep CRON /var/log/syslog
tail -f /var/log/syslog
bash script.sh


---

## Real World Use Cases
- Automated backups
- Deleting old logs
- Database dumps 
- System monitoring scripts 
- Scheduled maintenance 


---


## Skills Gained 

- Understanding cron scheduling syntax
- Automating tasks using cron
- Creating scheduled backup jobs
- Manainge cron jobs with crontab
- Troubleshooting failed cron jobs


---


#Environments Used

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
