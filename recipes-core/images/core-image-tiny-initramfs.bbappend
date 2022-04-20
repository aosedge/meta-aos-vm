VIRTUAL-RUNTIME_dev_manager ?= "busybox-mdev"

PACKAGE_INSTALL = " \
    initramfs-framework-base \
    busybox \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ' \
        packagegroup-selinux-minimal \
        policycoreutils-hll \
        policycoreutils-loadpolicy \
        ', '', d)} \
"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
