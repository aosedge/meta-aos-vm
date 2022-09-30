do_install_append() {
    sed -i -e 's#/.autorelabel#/var/aos/.autorelabel#g' ${D}${bindir}/${SELINUX_SCRIPT_SRC}.sh

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
       rm -f ${D}/.autorelabel
    fi
}

pkg_postinst_${PN}() {
    echo "# first boot relabelling" > $D/var/aos/.autorelabel
}
