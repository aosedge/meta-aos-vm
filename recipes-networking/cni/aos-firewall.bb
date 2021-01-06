
inherit go
inherit goarch

GO_IMPORT = "${PN}"
SRCREV = "${AUTOREV}"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI = "git://gitpct.epam.com/Valerii_Chubar/aos-filter-firewall.git;protocol=https;branch=core-logic;" 

do_compile() {
    cd ${S}/src/aos-firewall/plugins/meta/aos-firewall
    ${GO} build -o ${B}/bin/aos-firewall
}

do_install() {
    localbindir="${libexecdir}/cni/"
    install -d ${D}/${localbindir}
    install -m 755 ${B}/bin/aos-firewall ${D}/${localbindir}
}

FILES_${PN} = "${libexecdir}/cni/"

