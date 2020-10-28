FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "git://git@gitpct.epam.com/epmd-aepr/${GO_IMPORT}.git;protocol=ssh"

SRC_URI_append = "\
    file://aos-certificatemanager.service \
    file://aos_certificatemanager.cfg \
"

AOS_CM_CERT_MODULES = "\
    swmodule \
"

inherit systemd

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_certificatemanager.cfg \
    ${systemd_system_unitdir}/aos-certificatemanager.service \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_certificatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-certificatemanager.service ${D}${systemd_system_unitdir}/aos-certificatemanager.service

    install -d ${D}/var/aos/certificatemanager
}
