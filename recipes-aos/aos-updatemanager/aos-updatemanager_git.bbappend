FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-updatemanager.service \
    file://aos_updatemanager.cfg \
"

AOS_UM_UPDATE_MODULES ?= "\
    filemodule \
    overlaymodule \
    efidualpart \
"

inherit systemd

DEPENDS_append = "\
    pkgconfig-native \
    systemd \
    efivar \
"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_updatemanager.cfg \
    ${systemd_system_unitdir}/aos-updatemanager.service \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service

    install -d ${D}/var/aos/updatemanager
}
