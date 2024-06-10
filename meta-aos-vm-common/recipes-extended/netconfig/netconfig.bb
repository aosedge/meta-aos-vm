FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SUMMARY = "Network configuration files"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI += " \
    file://veth.network \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/veth.network ${D}${sysconfdir}/systemd/network/20-veth.network
}
