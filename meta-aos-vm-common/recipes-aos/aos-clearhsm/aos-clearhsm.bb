DESCRIPTION = "Aos script to clear PKCS11 storage"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://aos-clearhsm.sh \
"

S = "${WORKDIR}"

FILES:${PN} = " \
    ${bindir} \
"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/aos-clearhsm.sh ${D}${bindir}
}
