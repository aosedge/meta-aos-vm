FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS:append = " efivar"

SRC_URI += " \
    file://ipforwarding.conf \
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
}

do_install:append() {
    # Do not install headers files to prevent SDK build conflicts
    rm -rf ${D}${includedir}
}
