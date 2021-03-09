#!/bin/sh

ls -d /sys/class/net/*/device | cut -d/ -f5 |
while read -r line; do
    iptables -A INPUT -i $line -p tcp --dport 8089 -j DROP
    iptables -A INPUT -i $line -p udp --dport 8089 -j DROP
done
