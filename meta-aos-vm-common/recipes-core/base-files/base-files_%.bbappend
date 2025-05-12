FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://aos-dns.conf"

do_install:append() {
    # add home partition
    echo "\n# Home partition">> ${D}${sysconfdir}/fstab
    echo "/dev/${AOS_IMAGE_DISK}4            /home                ext4 \
        defaults,noatime       0  0" >> ${D}${sysconfdir}/fstab

    # add sync mount option to aos partitions
    sed -i '/\/var\/aos\//s/\(defaults,auto,\)/\1sync,/' ${D}${sysconfdir}/fstab

    # add aos DNS
    if [ -n "${AOS_DNS_IP}" ]; then
        install -d ${D}${sysconfdir}/systemd/resolved.conf.d
        install -m 0644 ${WORKDIR}/aos-dns.conf ${D}${sysconfdir}/systemd/resolved.conf.d/

        sed -i "s|@AOS_DNS_IP@|${AOS_DNS_IP}|g" ${D}${sysconfdir}/systemd/resolved.conf.d/aos-dns.conf
    fi
}
