FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "update_v3"

SRC_URI_append = " \
    file://aos_servicemanager.cfg \
    file://aos-servicemanager.service \
    file://aos.target \
    file://ipforwarding.conf \
    file://rootCA.pem \
    file://com.aos.servicemanage.conf \
"

AOS_SM_IDENTIFIERS = "\
    fileidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-servicemanager.service aos.target"

RDEPENDS_${PN} += "\
    libvis \
    nodejs\
    python3 \
    python3-compression \
    python3-core \
    python3-crypt \
    python3-json \
    python3-misc \
    python3-shell \
    python3-six \
    python3-threading \
    python3-websocket-client \
"

MIGRATION_SCRIPTS_PATH = "/usr/share/servicemanager/migration"
DBUS_CONF_PATH = "/usr/share/dbus-1/system.d"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_servicemanager.cfg \
    ${sysconfdir}/sysctl.d/*.conf \
    ${sysconfdir}/ssl/certs/*.pem \
    ${systemd_system_unitdir}/*.service \
    ${systemd_system_unitdir}/*.target \
    ${MIGRATION_SCRIPTS_PATH} \
    ${DBUS_CONF_PATH} \
"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.target ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${sysconfdir}/ssl/certs
    install -m 0644 ${WORKDIR}/rootCA.pem ${D}${sysconfdir}/ssl/certs/

    install -d ${D}/var/aos/servicemanager

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="/src/aos_servicemanager/database/migration"
    if [ -d ${S}${source_migration_path} ]; then
        install -m 0644 ${S}${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi

    install -d ${D}${DBUS_CONF_PATH}
    install -m 0644 ${WORKDIR}/com.aos.servicemanage.conf ${D}${DBUS_CONF_PATH}

}

pkg_postinst_${PN}() {
    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi

    # Add aossm to /etc/hosts
    if ! grep -q 'aossm' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aossm' >> $D${sysconfdir}/hosts
    fi

    # Add aosiam to /etc/hosts
    if ! grep -q 'aosiam' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aosiam' >> $D${sysconfdir}/hosts
    fi
}
