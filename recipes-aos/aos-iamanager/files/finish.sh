# !/bin/sh

rm -rf /var/unprovisioned_state
systemctl restart aos.target
