FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
    file://finish.sh \
"

AOS_IAM_CERT_MODULES = "\
    certhandler/modules/pkcs11module \
"

AOS_IAM_IDENT_MODULES = "\
    identhandler/modules/visidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${bindir} \
"

RDEPENDS_${PN} = " \
    aos-provfirewall \
    softhsm \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/finish.sh ${D}${bindir}

    install -d ${D}${localstatedir}/aos
    touch ${D}${localstatedir}/aos/.unprovisioned
}
