PACKAGE_INSTALL = " \
    initramfs-module-aosupdate \
    initramfs-module-lvm \
    initramfs-module-machineid \
    initramfs-module-opendisk \
    initramfs-module-rundir \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'initramfs-module-selinux', '', d)} \
    initramfs-module-udev \
    initramfs-module-vardir \
    kernel-module-overlay \
    kernel-module-squashfs \
    busybox \
    lvm2 \
    softhsm \
"
