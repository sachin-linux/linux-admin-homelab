# U4 - Logs (journalctl Deep Dive)

## Objective
Understand Linux logging and diagnose system issue using logs.

## Topics Covered

- systemd journal
- journalctl commands
- system boot logs
- authentication logs
- log monitoring
- logrotate configuration

## Key Commands

journalctl 
journalctl -f
journalctl -u ssh
journalctl -b
journalctl --since "1 hour ago"

## Log Locations

/var/log/syslog
/var/log/auth.log
/var/log/kern.log

## Monitoring Logs

Follow logs in real time

journalctl -f

Check SSH logs

journalctl -u ssh

Check boot logs

journalctl -b

## Log Rotation 

Configuration file

/etc/logrotate.conf

Application configuration

/etc/logrotate.d/

## Lab

1. View boot logs
2. Monitor SSH authentication logs
3. Follow logs in real time
4. Trigger service restart and observe logs
5. Force log rotation

## Skills Gained

- Log analysis 
- Troubleshooting services
- Monitoring authentication events
