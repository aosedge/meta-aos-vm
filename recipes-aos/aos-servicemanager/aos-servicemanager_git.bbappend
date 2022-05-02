FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos_servicemanager.cfg \
    file://aos-servicemanager.service \
    file://aos.target \
    file://ipforwarding.conf \
    file://rootCA.pem \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-servicemanager.service aos.target"

RDEPENDS_${PN} += "\
    python3 \
    python3-core \
"

MIGRATION_SCRIPTS_PATH = "${base_prefix}/usr/share/aos/sm/migration"

AOS_RUNNER ?= "crun"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${MIGRATION_SCRIPTS_PATH} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}${sysconfdir}/aos

    sed -i 's/"runner": "runc",/"runner": "${AOS_RUNNER}",/g' ${D}${sysconfdir}/aos/aos_servicemanager.cfg

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-servicemanager.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos.target ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/ssl/certs
    install -m 0644 ${WORKDIR}/rootCA.pem ${D}${sysconfdir}/ssl/certs/

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="/src/${GO_IMPORT}/database/migration"
    if [ -d ${S}${source_migration_path} ]; then
        install -m 0644 ${S}${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}

pkg_postinst_${PN}() {
    # Add aossm to /etc/hosts
    if ! grep -q 'aossm' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aossm' >> $D${sysconfdir}/hosts
    fi
}
