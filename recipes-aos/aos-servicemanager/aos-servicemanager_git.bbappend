FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "update_v3"

SRC_URI_append = " \
    file://aos_servicemanager.cfg \
    file://aos-servicemanager.service \
    file://aos.target \
    file://ipforwarding.conf \
    file://rootCA.pem \
"

AOS_SM_IDENTIFIERS = "\
    fileidentifier \
"

inherit systemd

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

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_servicemanager.cfg \
    ${sysconfdir}/sysctl.d/*.conf \
    ${sysconfdir}/ssl/certs/*.pem \
    ${systemd_system_unitdir}/*.service \
    ${systemd_system_unitdir}/*.target \
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
}

pkg_postinst_${PN}() {
    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi

    # Add wwwaosum to /etc/hosts
    if ! grep -q 'wwwaosum' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	wwwaosum' >> $D${sysconfdir}/hosts
    fi
}
