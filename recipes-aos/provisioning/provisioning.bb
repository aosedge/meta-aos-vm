DESCRIPTION = "Dom0 scripts used for AOS provisioning"

LICENSE = "CLOSED"

SRCREV = "${AUTOREV}"
SRC_URI = "git://git@gitpct.epam.com/epmd-aepr/aos_provisioning.git;protocol=ssh"

S = "${WORKDIR}/git"

FILES_${PN} = " \
    /xt/scripts/aos-provisioning.step1.sh \
    /xt/scripts/aos-provisioning.step2.sh \
"

RDEPENDS_${PN} = "bash"

do_install() {
    install -d ${D}/xt/scripts
    install -m 0755 ${S}/aos-provisioning.step1.sh ${D}/xt/scripts
    install -m 0755 ${S}/aos-provisioning.step2.sh ${D}/xt/scripts
}
