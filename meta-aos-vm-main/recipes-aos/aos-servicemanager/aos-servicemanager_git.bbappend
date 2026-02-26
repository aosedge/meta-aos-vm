FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://resources.cfg \
"

do_install:append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/resources.cfg ${D}${sysconfdir}/aos
}
