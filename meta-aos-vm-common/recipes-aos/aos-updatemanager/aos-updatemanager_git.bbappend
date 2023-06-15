FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-reboot.service \
    file://aos-dirs-service.conf \
    file://reboot-on-failure.conf \
"

AOS_UM_UPDATE_MODULES = " \
    updatemodules/overlaysystemd \
    updatemodules/efidualpart \
"

inherit systemd

RDEPENDS:${PN} += " \
    efibootmgr \
"

FILES:${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}${sysconfdir}/systemd/system/aos-updatemanager.service.d
    install -m 0644 ${WORKDIR}/reboot-on-failure.conf ${D}${sysconfdir}/systemd/system/aos-updatemanager.service.d/20-reboot-on-failure.conf
}
