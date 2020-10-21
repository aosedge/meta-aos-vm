FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append() {
    sed -i -e "s/\/lib\/systemd\/systemd-quotacheck/\/usr\/sbin\/quotacheck -avum/" \
          ${D}${systemd_unitdir}/system/systemd-quotacheck.service
}
