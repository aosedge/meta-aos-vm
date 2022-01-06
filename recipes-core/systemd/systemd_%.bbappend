quotacheck_srv = "systemd-quotacheck.service"
quotaon_srv = "quotaon.service"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://crypttab \
    file://override.conf \
    file://70-veth.network \
"

FILES_${PN} += " ${sysconfdir} \"

PACKAGECONFIG[p11kit] = "-Dp11kit=true -Dhomed=false, -Dp11kit=false, p11-kit"

PACKAGECONFIG_append += " cryptsetup p11kit openssl "

do_install_append () {
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants

    sed -i -e "s/\/lib\/systemd\/systemd-quotacheck/\/usr\/sbin\/quotacheck -avum/" \
         ${D}${systemd_unitdir}/system/${quotacheck_srv}

    sed -i -e "/^.*\/var\/volatile\/log.*$/d" ${D}${sysconfdir}/tmpfiles.d/00-create-volatile.conf

    ln -sf ${systemd_unitdir}/system/${quotacheck_srv} ${D}${sysconfdir}/systemd/system/multi-user.target.wants/${quotacheck_srv}
    ln -sf ${systemd_unitdir}/system/${quotaon_srv} ${D}${sysconfdir}/systemd/system/multi-user.target.wants/${quotaon_srv}

    install -d ${D}${sysconfdir}/
    install -m 0644 ${WORKDIR}/crypttab ${D}${sysconfdir}/

    install -d ${D}${sysconfdir}/systemd/system/systemd-cryptsetup@aos_partition.service.d/
    install -m 0644 ${WORKDIR}/override.conf ${D}${sysconfdir}/systemd/system/systemd-cryptsetup@aos_partition.service.d/

    install -d ${D}${systemd_unitdir}/network/
    install -m 0644 ${WORKDIR}/70-veth.network ${D}${systemd_unitdir}/network/
}
