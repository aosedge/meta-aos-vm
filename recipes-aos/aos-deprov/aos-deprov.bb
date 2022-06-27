DESCRIPTION = "Aos unprovisioning script"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://aos-deprov.sh \
"

S = "${WORKDIR}"

FILES_${PN} = " \
    ${bindir} \
"

RDEPENDS_${PN} = "aos-setupdisk"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/aos-deprov.sh ${D}${bindir}
}
