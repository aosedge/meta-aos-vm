do_install:append() {
    for host in ${AOS_HOSTS}; do
        echo ${host} | sed "s/=/ /g" >> ${D}${sysconfdir}/hosts
    done

    # add home partition
    echo "\n# Home partition">> ${D}${sysconfdir}/fstab
    echo "/dev/${AOS_IMAGE_DISK}4            /home                ext4 \
        defaults,noatime       0  0" >> ${D}${sysconfdir}/fstab
}
