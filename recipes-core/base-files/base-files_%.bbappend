FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "file://fstab.append"

do_install_append() {
    cat fstab.append >> ${D}/${sysconfdir}/fstab
}
