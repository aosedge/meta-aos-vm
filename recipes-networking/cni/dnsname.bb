FILESEXTRAPATHS_append := "${THISDIR}/${PN}:" 

inherit go
inherit goarch

RDEPENDS_${PN}-dev += "bash"
GO_IMPORT = "dnsname"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

# Version v1.1.1
SRCREV = "c654c95366ac5f309ca3e5727c9b858864247328"
SRC_URI = "git://github.com/containers/dnsname \
           file://0001-resolve-local-hostnames.patch;patchdir=${S}/src/${GO_IMPORT}"

do_install() {
    localbindir="${libexecdir}/cni/"
    install -d ${D}/${localbindir}
    install -m 755 ${B}/bin/dnsname ${D}/${localbindir}
}

FILES_${PN} = "${libexecdir}/cni/"

