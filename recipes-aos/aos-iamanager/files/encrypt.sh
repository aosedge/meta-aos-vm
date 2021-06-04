#!/bin/sh

PIN=$(cat /var/.usrpin.txt)

PASSWORD="$(dd if=/dev/urandom bs=10 count=1)"

echo PIN=$PIN > /var/.usrpin;

echo $PASSWORD | cryptsetup  -q --type luks2 luksFormat /dev/hda6

PASSWORD=$PASSWORD  PIN=$PIN systemd-cryptenroll --pkcs11-token-uri="pkcs11:token=aos;object=diskencryption" /dev/hda6

echo $PASSWORD | cryptsetup luksRemoveKey /dev/hda6

PIN=$PIN /lib/systemd/systemd-cryptsetup attach aos_partition /dev/hda6 - pkcs11-uri=auto

mkfs.ext4 /dev/mapper/aos_partition

sync
reboot
