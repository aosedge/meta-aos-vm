FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
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
"

RDEPENDS_${PN} = " \
    aos-provfirewall \
    aos-provfinish \
    softhsm \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}
}
