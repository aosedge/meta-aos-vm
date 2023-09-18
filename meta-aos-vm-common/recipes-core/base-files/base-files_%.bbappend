do_install:append() {
    # add home partition
    echo "\n# Home partition">> ${D}${sysconfdir}/fstab
    echo "/dev/${AOS_IMAGE_DISK}4            /home                ext4 \
        defaults,noatime       0  0" >> ${D}${sysconfdir}/fstab
}
