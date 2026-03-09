# U3 - Service Management (systemd)

## Objective

- systemctl commands
- Service lifecycle management 
- Enabling services at boot
- Viewing serive status
- Troubleshooting failed services
- Creating custom systemd services

## Key Commands

systemctl start
systemctl stop
systemctl status
systemctl enable
systemctl disable

Example

systemctl status nginx

## Viewing Logs

journalctl -u nginx

## Creating Custom Service

Service giles are located in:

/etc/systemd/system/

Example service:

hello.service

Example Script:

/usr/local/bin/hello.sh

Enable service

sudo systemctl enable hello

Start service

sudo systemctl start hello

## Lab

1. Install nginx
2. Start and stop service
3. Enable service at boot
4. Create custom service
5. View service logs

## Skills Gained

- Managing Linux services
- Service troubleshooting 
- Creating custom systemd services

---

## Environment Used
Ubuntu Linux
VirtualBox
Linux CLI tools
