FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS:append = " efivar"

SRC_URI += " \
    file://ipforwarding.conf \
    file://resources.cfg \
"

FILES:${PN} += " \
    ${sysconfdir} \
"

# Base layer for services
RDEPENDS:${PN} += "\
    python3 \
    python3-core \
"

do_install:append() {
    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/resources.cfg ${D}${sysconfdir}/aos
}
