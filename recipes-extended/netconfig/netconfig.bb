FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SUMMARY = "Network configuration files"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI += "\
    file://eth.network \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/*.network ${D}${sysconfdir}/systemd/network
}

pkg_postinst_ontarget_${PN} () {
    # Add hostname to /etc/hosts
    if ! grep -q '${MACHINE}' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	${MACHINE}' >> $D${sysconfdir}/hosts
    fi
}