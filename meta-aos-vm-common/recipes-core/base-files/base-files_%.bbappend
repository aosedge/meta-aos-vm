do_install_append() {
    for host in ${HOST_NAMES}; do
        echo ${host} | sed "s/=/ /g" >> ${D}${sysconfdir}/hosts
    done
}
