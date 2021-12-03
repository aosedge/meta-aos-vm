#!/bin/sh

# Disable SELinux on first boot in order to proper
# start of system services before relabeling
if [ -f /var/aos/.first_boot ]; then
    /usr/sbin/setenforce 0
    /bin/rm -f /var/aos/.first_boot
fi

/sbin/fixfiles -F -f relabel

exit 0
