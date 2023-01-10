#!/bin/sh

# use systemctl stop all aos.target services instead of systemctl stop aos.target, because this approach doesn't wait
# all services really stopped.
systemctl stop -- $(systemctl show -p Wants aos.target | cut -d= -f2)

# delete Aos disks
/opt/aos/setupdisk.sh delete

# remove IAM DB and PKCS11 storage
rm /var/aos/iam -rf
rm /var/lib/softhsm/tokens/* -rf

# restore unprovisioned flag
touch /var/aos/.unprovisioned

systemctl start aos.target
