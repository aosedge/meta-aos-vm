FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos_vis.cfg \
    file://aos-vis.service \
"

AOS_VIS_PLUGINS ?= "\
    plugins/vinadapter \
    plugins/boardmodeladapter \
    plugins/subjectsadapter \
    plugins/telemetryemulatoradapter \
    plugins/renesassimulatoradapter \
"

VIS_CERTS_PATH = "${base_prefix}/usr/share/aos/vis/certs"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-vis.service"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${VIS_CERTS_PATH} \
    ${localstatedir} \
"

RDEPENDS_${PN} += "\
    aos-rootca \
    ${@bb.utils.contains('AOS_VIS_PLUGINS', 'plugins/telemetryemulatoradapter', 'telemetry-emulator', '', d)} \
"

do_install_append() {
    if "${@bb.utils.contains('AOS_VIS_PLUGINS', 'plugins/telemetryemulatoradapter', 'true', 'false', d)}"; then
        if ! grep -q 'network-online.target telemetry-emulator.service' ${WORKDIR}/aos-vis.service ; then
            sed -i -e 's/network-online.target/network-online.target telemetry-emulator.service/g' ${WORKDIR}/aos-vis.service
        fi

        if ! grep -q 'ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service ; then
            sed -i -e '/ExecStart/i ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service
        fi
    fi

    install -d ${D}/${localstatedir}/aos/vis

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_vis.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-vis.service ${D}${systemd_system_unitdir}/aos-vis.service

    install -d ${D}${VIS_CERTS_PATH}
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}${VIS_CERTS_PATH}
}

pkg_postinst_${PN}() {
    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi
}
