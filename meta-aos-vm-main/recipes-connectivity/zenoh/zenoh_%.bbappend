FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://zenohd.json5 \
"

do_install:append() {
    install -d 755 ${D}${sysconfdir}/zenohd
    install -m 644 ${WORKDIR}/zenohd.json5 ${D}${sysconfdir}/zenohd
}
