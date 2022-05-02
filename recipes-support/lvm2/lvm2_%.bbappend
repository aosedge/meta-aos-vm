do_install_append () {
    # put cache, backup etc. into RW /var/lvm
    sed -i "s:/etc:/var:g" ${D}${sysconfdir}/lvm/lvm.conf
}
