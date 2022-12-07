LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://aos-selinux-autorelabel.service \
    file://aos-selinux-autorelabel.sh \
"

FILES_${PN} += " \
    ${systemd_system_unitdir}/*.service \
"

inherit systemd

do_configure[noexec] = "1"
do_compile[noexec] = "1"

SYSTEMD_SERVICE_${PN} = "aos-selinux-autorelabel.service"

do_install() {
    install -Dm 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}/aos-selinux-autorelabel.service
    install -Dm 0755 ${WORKDIR}/aos-selinux-autorelabel.sh ${D}/${bindir}/aos-selinux-autorelabel.sh
}

pkg_postinst_${PN}() {
    echo "# first boot relabelling" > $D/var/aos/.first_boot
}
