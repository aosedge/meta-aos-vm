FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

aos_firewall_srv:= "aos-firewall.service"
iptables_rules_scr := "iptables-rules.sh"

BRANCH = "master"

SRC_URI_append = "\
    file://aos-iamanager.service \
    file://aos_iamanager.cfg \
    file://finish.sh \
    file://${aos_firewall_srv} \
    file://${iptables_rules_scr} \
"

AOS_IAM_CERT_MODULES = "\
    certhandler/modules/swmodule \
"

AOS_IAM_IDENT_MODULES = "\
    identhandler/modules/visidentifier \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service"
SYSTEMD_SERVICE_${PN} += " ${aos_firewall_srv}"

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_iamanager.cfg \
    ${systemd_system_unitdir}/aos-iamanager.service \
    /var/aos/finish.sh \
    ${systemd_system_unitdir}/${aos_firewall_srv} \
    ${bindir}/${iptables_rules_scr} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-iamanager.service ${D}${systemd_system_unitdir}/aos-iamanager.service

    install -d ${D}/var/aos/iamanager
    install -m 0755 ${WORKDIR}/finish.sh ${D}/var/aos/finish.sh

    install -m 0644 /dev/null ${D}/var/aos/unprovisioned_state

    install -D -m 0644 ${WORKDIR}/${aos_firewall_srv} ${D}${systemd_system_unitdir}
    install -D -m 0744 ${WORKDIR}/${iptables_rules_scr} ${D}${bindir}
}
