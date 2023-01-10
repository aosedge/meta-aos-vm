FILESEXTRAPATHS_append := "${THISDIR}/base-files:"

hostname = "${NODE_ID}"

do_install_append() {
    echo "${MAIN_NODE_ID}:/var/aos/storages      /var/aos/storages    nfs4       defaults,nofail,noatime,x-systemd.automount    0  0" >> ${D}${sysconfdir}/fstab
    echo "${MAIN_NODE_ID}:/var/aos/states        /var/aos/states      nfs4       defaults,nofail,noatime,x-systemd.automount    0  0" >> ${D}${sysconfdir}/fstab
}
