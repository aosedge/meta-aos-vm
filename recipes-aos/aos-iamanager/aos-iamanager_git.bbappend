FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "master"

SRC_URI_append = "\
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
    file://finish.sh \
"

AOS_IAM_CERT_MODULES = "\
    certhandler/modules/swmodule \
"

AOS_IAM_IDENT_MODULES = "\
    identhandler/modules/visidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_iamanager.cfg \
    ${systemd_system_unitdir}/aos-iamanager.service \
    /var/aos/finish.sh \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-iamanager.service ${D}${systemd_system_unitdir}/aos-iamanager.service

    install -d ${D}/var/aos/iamanager
    install -m 0755 ${WORKDIR}/finish.sh ${D}/var/aos/finish.sh
}
