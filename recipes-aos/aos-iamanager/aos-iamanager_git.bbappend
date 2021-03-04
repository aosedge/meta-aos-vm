FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "master"

SRC_URI_append = "\
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
    file://finish.sh \
    file://aos-firewall.service \
    file://iptables-rules.sh \
"

AOS_IAM_CERT_MODULES = "\
    certhandler/modules/swmodule \
"

AOS_IAM_IDENT_MODULES = "\
    identhandler/modules/visidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service aos-firewall.service"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${bindir} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/*.service ${D}${systemd_system_unitdir}

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/finish.sh ${D}${bindir}
    install -m 0744 ${WORKDIR}/iptables-rules.sh ${D}${bindir}

    install -d ${D}/var/aos
    install -m 0644 /dev/null ${D}/var/aos/unprovisioned_state
}
