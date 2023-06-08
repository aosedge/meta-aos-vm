DESCRIPTION = "Export Aos states and storages folder for other nodes"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

do_install() {
    install -d ${D}${sysconfdir}

    echo "/var/aos/storages *(rw,no_root_squash,sync,no_wdelay,no_subtree_check)" >> ${D}${sysconfdir}/exports
    echo "/var/aos/states   *(rw,no_root_squash,sync,no_wdelay,no_subtree_check)" >> ${D}${sysconfdir}/exports
}

RDEPENDS:${PN} = "packagegroup-core-nfs-server"
