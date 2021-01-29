#!/bin/sh
iptables -A INPUT -p tcp --dport 8089 -j DROP
iptables -A INPUT -p udp --dport 8089 -j DROP
