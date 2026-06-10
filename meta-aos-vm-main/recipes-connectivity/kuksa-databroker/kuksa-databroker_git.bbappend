FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://vss_release_5.1.json \
"

RDEPENDS:${PN}:remove = "vss"

FILES:${PN} += "${datadir}/vss/vss.json"

do_install:append() {
    install -d ${D}${datadir}/vss/
    install -m 0644 ${WORKDIR}/vss_release_5.1.json ${D}${datadir}/vss/vss.json
}
