FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS:append = " efivar"

SRC_URI += " \
    file://ipforwarding.conf \
    file://resources.cfg \
    file://resources-benchmark.cfg \
"

FILES:${PN} += " \
    ${sysconfdir} \
"

# Base layer for services
RDEPENDS:${PN} += "\
    python3 \
    python3-core \
"

do_install:append() {
    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/aos
    # resources-benchmark.cfg additionally adds a victoria-metrics resource (only VictoriaMetrics
    # runs on the main node - see meta-aos's aos-image.inc).
    install -m 0644 ${WORKDIR}/${@bb.utils.contains('DISTRO_FEATURES', 'benchmark', 'resources-benchmark.cfg', 'resources.cfg', d)} \
        ${D}${sysconfdir}/aos/resources.cfg
}
