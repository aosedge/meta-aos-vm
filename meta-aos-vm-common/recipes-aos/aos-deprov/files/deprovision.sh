#!/bin/sh

{
    sleep 1

    # use systemctl stop all aos.target services instead of systemctl stop aos.target, because this approach doesn't wait
    # all services really stopped.
    systemctl stop -- $(systemctl show -p Wants aos.target | cut -d= -f2)

    #restore unprovisioned flag
    rm /var/aos/.provisionstate -f

    # remove IAM DB and PKCS11 storage
    rm /var/aos/iam -rf
    rm /var/lib/softhsm/tokens/* -rf

    # delete Aos disks
    /opt/aos/setupdisk.sh delete | systemd-cat

    sync

    systemctl start aos.target
} > /dev/null 2>&1 &
