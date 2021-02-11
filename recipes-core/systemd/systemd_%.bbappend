quotacheck_srv = "systemd-quotacheck.service"
quotaon_srv = "quotaon.service"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append () {
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants

    sed -i -e "s/\/lib\/systemd\/systemd-quotacheck/\/usr\/sbin\/quotacheck -avum/" \
         ${D}${systemd_unitdir}/system/${quotacheck_srv}

    sed -i -e "/^.*\/var\/volatile\/log.*$/d" ${D}${sysconfdir}/tmpfiles.d/00-create-volatile.conf

    ln -sf ${systemd_unitdir}/system/${quotacheck_srv} ${D}${sysconfdir}/systemd/system/multi-user.target.wants/${quotacheck_srv}
    ln -sf ${systemd_unitdir}/system/${quotaon_srv} ${D}${sysconfdir}/systemd/system/multi-user.target.wants/${quotaon_srv}
}
