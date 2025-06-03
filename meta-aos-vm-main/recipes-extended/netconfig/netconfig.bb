FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SUMMARY = "Network configuration files"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI += " \
    file://wired.network \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/wired.network ${D}${sysconfdir}/systemd/network/20-wired.network

    if [ ${AOS_USE_DHCP} = "1" ]; then
        echo "DHCP=yes" >> ${D}${sysconfdir}/systemd/network/20-wired.network
        echo "Address=${AOS_NODE_IP}" >> ${D}${sysconfdir}/systemd/network/20-wired.network
    else
        echo "Address=${AOS_NODE_IP}" >> ${D}${sysconfdir}/systemd/network/20-wired.network
        echo "Gateway=${AOS_NODE_GW_IP}" >> ${D}${sysconfdir}/systemd/network/20-wired.network
        echo "DNS=${AOS_NODE_GW_IP}" >> ${D}${sysconfdir}/systemd/network/20-wired.network
    fi

    if [ -n "${AOS_DNS_IP}" ]; then
        echo "DNS=${AOS_DNS_IP}" >> ${D}${sysconfdir}/systemd/network/20-wired.network
    fi
}
