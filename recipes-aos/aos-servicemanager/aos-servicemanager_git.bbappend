FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos_servicemanager.cfg \
    file://aos-servicemanager.service \
    file://ipforwarding.conf \
    file://root_dev.conf \
    file://rootCA.crt \
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
    /var/aos/servicemanager/aos_servicemanager.cfg \
    ${datadir}/ca-certificates/aos/*.crt \
    ${sysconfdir}/sysctl.d/*.conf \
    ${sysconfdir}/tmpfiles.d/*.conf \
    ${systemd_system_unitdir}/*.service \
"

do_install_append() {
    install -d ${D}/var/aos/servicemanager
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}/var/aos/servicemanager

    install -d ${D}/var/aos/servicemanager/data/fcrypt

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/root_dev.conf ${D}${sysconfdir}/tmpfiles.d

    install -d ${D}${datadir}/ca-certificates/aos
    install -m 0644 ${WORKDIR}/rootCA.crt ${D}${datadir}/ca-certificates/aos
}

pkg_postinst_${PN}() {
    # Add AOS certificate
    if ! grep -q 'aos/rootCA.crt' $D/etc/ca-certificates.conf ; then
        echo 'aos/rootCA.crt' >> $D/etc/ca-certificates.conf
    fi

    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi

    sed -ie '/^\/dev\/root/ s/\<defaults\>/defaults,usrjquota=aquota.user,jqfmt=vfsv0/' $D/etc/fstab
}

pkg_postinst_ontarget_${PN} () {
    # Enable quotas
    echo "Enable disk quotas"
    quotacheck -avum && quotaon -avu

    # Update certificates
    echo "Update certificates"
    update-ca-certificates
}
