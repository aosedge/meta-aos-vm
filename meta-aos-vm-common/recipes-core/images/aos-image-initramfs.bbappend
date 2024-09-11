AOS_INITRAMFS_SCRIPTS += " \
    initramfs-module-lvm \
    initramfs-module-opendisk \
    initramfs-module-rundir \
    lvm2 \
    softhsm \
"

python () {
    if 'selinux' in d.getVar('DISTRO_FEATURES').split():
        d.setVar('INITRAMFS_MAXSIZE', '225082')
}
