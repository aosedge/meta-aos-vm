FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

FILES:${PN} += " \
    ${sysconfdir}/systemd/system/aos-iamanager.service.d/ \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/system/aos-iamanager.service.d
}
