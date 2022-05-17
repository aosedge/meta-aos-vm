PACKAGE_INSTALL = " \
    initramfs-module-rundir \
    initramfs-module-udev \
    initramfs-module-lvm \
    initramfs-module-opendisk \
    initramfs-module-aosupdate \
    kernel-module-overlay \
    kernel-module-squashfs \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'initramfs-module-selinux', '', d)} \
    busybox \
    softhsm \
    lvm2 \
"
