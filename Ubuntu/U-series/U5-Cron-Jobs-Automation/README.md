# Lab Title: U5-Cron-Jobs-Automation

## Objective	
Learn to automate repetitive tasks in Linux using cron jobs and systemd timers.

##Prerequisites
- Ubuntu server running
- Sudo access
- Basic Linux command knowledge
- Terminal access

## Steps / Instructions

### 1. Step one
```bash
sudo systemctl status cron
sudo systremctl start cron	# if not running
sudo system enable cron		# start at boot

### 2. Step two
crontab -l			# user
sudo crontab -l 		# root

### 3. Create Test Script
echo 'echo "$(date) - Cron test executed" >> /tmp/cron-test.log' > /home/user/test-script.sh
chmod +x /home/user/test-script.sh

### 4. Add Cron Job for Current user
Crontab -e
* * * * * /home/user/test-script.sh

### 5. Add Cron Job for Root User (Optional)
sud crontab -e
* * * * * echo "root cron executed $(date)" >> /tmp/root-cron.log

### 6. Verify Cron Job Execution
cat /tmp/cron-test.log
sudo cat /tmp/root-cron/log

### 7. Optional: Advanced Cron Feautres
- Run job at system boot: `@reboot /home/user/startup-script/sh`
- Check systemd timers: `sudo systemctl list-timers`

## Commands Used
Crontab -l
Crontab -e
sudo crontab -l
sudo crontab -e
sudo systemctl status/start/enable cron
chmod +x /home/user/test-script.sh
cat /tmp/cron-test.log
sudo cat /tmp/root-cron.log

## Skills Learned
- Automating tasks using cron jobs
- Editing user and system crontabs
- Managing cron service
- Creating test scripts
- Verifying scheduled tasks
- Optional: systemd timers for advance scheduling

## Result / Verification
- Cron jobs executed successfully at scheduled intervals.
- Test script appended timestamps to `/tmp/cron-test.log`.
- Root cron script appended timestamps to `/tmp/root-cron.log`.
- Cron service verified to start on boot.
