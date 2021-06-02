FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://softhsm.module \
"

do_install_append () {
    install -d ${D}${sysconfdir}/pkcs11/modules/
    install -m 0644 ${WORKDIR}/softhsm.module ${D}${sysconfdir}/pkcs11/modules/
}