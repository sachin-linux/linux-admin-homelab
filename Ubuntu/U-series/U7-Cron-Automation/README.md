# U7 - Cron Automation

## Objective

This module covers task automation in Linux using Cron.
Cron allows administrators to schedule commands or scripts to run automatically at specified times.

Automation is widely used in production environments for tasks like backups, log cleanup, monitoring, and system maintenance.

--------------------------------------------------

## Cron Service

Cron runs as a background service.

Check cron status 

systemctl status cron

start cron service 

sudo systemctl start cron

Enable cron at boot

sudo systemctl enable cron

--------------------------------------------------

## Crontab Commands

Each user has their own cron table.

Edit cron jobs

crontab -e

List cron jobs

crontab -l

Remove all cron jobs

crontab -r

Edit another user cron (root)

sudo crontab -u username -e

--------------------------------------------------

## Cron Syntax

Cron uses five time followed by the command.

* * * * * command
| | | | |
| | | | ----- Day of week (0-7) Sunday = 0
| | | ------- Month (1-12)
| | --------- Day of month (1-31)
| ----------- Hour (0-23)
------------- Minute (0-59)

Example 

0 2 * * * /home/user/backup.sh

This runs the script every day at 2:00 AM.

--------------------------------------------------

## Common Cron Examples

Run every minute

* * * * * command 

Run every 5 minutes

*/5 * * * * command

Run every hour

0 * * * * command

Run daily at midnight 

0 0 * * * command

Run every Sunday at 3 AM

0 3 * * 0 command

Run on the first day of every month 

0 0 1 * * command 

--------------------------------------------------

## Special Cron Keywords

Cron also supports special scheduling keywords.

@reboot
@yearly 
@monthly
@weekly
@daily 
@hourly

Example

@reboot /home/user/starup.sh 

This runs the script when the system starts.

--------------------------------------------------

## System Cron Jobs

System wide cron configuration file

/etc/crontab

Format 

minute hour day month weekday user command

Example

0 2 * * * root /scripts/backup.sh

--------------------------------------------------

## Cron Directories

Linux automatically runs scripts placed in these directories.

/etc/cron.hourly
/etc/cron.daily
/etc/cron.weekly
/etc/cron.monthly

Example

sudo cp cleanup.sh /etc/cron.daily/

--------------------------------------------------

## Cron Logs

Cron activity is recorded in system logs.

View cron logs

grep CRON /var/log/syslog

Monitor logs live

tail -f /var/log/syslog

Example output

CRON[1234]: (user) CMD (/home/user/script/sh)

--------------------------------------------------

## Cron Environment Issue 

Cron runs with a minimal environment.

Incorrect 

pyhton script.py

Correct 

/usr/bin/pyhton3 /home/user/script.py

Always use full paths in cron jobs.

--------------------------------------------------

## Redirecting Cron Output

To capture output and error in a log file

* * * * * /home/user/script/sh >> /var/log/script.log 2>&1

>> appends output 
2>&1 redirects errors

--------------------------------------------------

## Cron Security

Control which users can use cron. 

/etc/cron.allow
/etc/cron.deny

If cron.allow exists, only users listed in that file can use cron.

Example 

echo user | sudo tee -a /etc/cron.allow

--------------------------------------------------

## Cron Troubleshooting

If a cron job fails check the following

1 Check cron serivce

systemctl status cron

2 Check cron logs

grep CRON /var/log/syslog

3 Ensure script is executable

chmod +x script.sh

4 Use full paths in commands

5 Test script manually

bash script.sh

--------------------------------------------------

## Lab 1 - Basic Cron Job

Create a script

nano cron-test.sh

Script

#!/bin/bash
echo "Cron executed at $(date)" >> /tmp/cron-test.log

Make executable

Chmod +x cron-test.sh

Add cron job 

crontab -e

Add 

* * * * * /home/user/cron-test.sh

Verify 

cat /tmp/cron-test.log

--------------------------------------------------

## Lab 2 - Automated Backup

Create backup script 

nano backup.sh

Script 

#!/bin/bash

SOURCE="/home/user/Documents"
DEST="/home/user/backups"

mkdir -p $DEST

tar -czf $DEST/backup-$(date +%F)/tar.gz $SOURCE

Make executable

chmod +x backup.sh

Add cron job

0 2 * * * /home/user/backup.sh

--------------------------------------------------

## Lab 3 - Log Cleanup Automation

Create cleanup script 

nano cleanup.sh

Script 

#!/bin/bash 

find /tmp -name "*.log" -type f -mtime +7 -delete

Make executable 

chmod +x cleanup.sh

Add cron job

0 3 * * * * /home/user/cleanup.sh

--------------------------------------------------

## Lab 4 - Cron Troubleshooting

Check cron service 

systemctl status cron

Check cron logs

grep CRON /var/log/syslog

Monitor logs

tail -f /var/log/syslog

Test scripts manually

bash script.sh

--------------------------------------------------

## Real World Use Cases

Cron is commonly used for:

- automated backups
- deleting old logs
- database dumps 
- system monitoring scripts 
- scheduled maintenance 

Automation ensures tasks run consistently without manual intervention.

--------------------------------------------------

## Skills Gained 

- Understand cron scheduling
- Automate tasks using cron
- Create scheduled backup jobs
- Manage cron jobs with crontab
- Troubleshoot failed cron jobs
