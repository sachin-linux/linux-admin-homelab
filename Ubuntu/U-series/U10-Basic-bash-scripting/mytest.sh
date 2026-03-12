#!/bin/bash

echo "===== My Server Report ====="

echo "User: $(whoami)"
echo "Date: $(date)"
echo "Directory: $(pwd)"

#check if cron is running
if systemctl is-active --quiet cron; then
	echo "Cron is running"
else
	echo "Cron is DOWN"
fi
