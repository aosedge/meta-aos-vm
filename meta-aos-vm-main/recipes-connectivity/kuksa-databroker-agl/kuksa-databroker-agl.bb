FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SUMMARY = "AGL options for KUKSA.val databroker"
HOMEPAGE = "https://github.com/eclipse/kuksa.val"
BUGTRACKER = "https://github.com/eclipse/kuksa.val/issues"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://kuksa-databroker.env"

inherit allarch update-alternatives

do_install() {
    install -d ${D}${sysconfdir}/default
    install -m 0644 ${WORKDIR}/kuksa-databroker.env ${D}${sysconfdir}/default/kuksa-databroker.agl
}

ALTERNATIVE:${PN} = "kuksa-databroker-env"
ALTERNATIVE_LINK_NAME[kuksa-databroker-env] = "${sysconfdir}/default/kuksa-databroker"
ALTERNATIVE_TARGET[kuksa-databroker-env] = "${sysconfdir}/default/kuksa-databroker.agl"

RDEPENDS:${PN} += "kuksa-databroker kuksa-certificates-agl vss"
