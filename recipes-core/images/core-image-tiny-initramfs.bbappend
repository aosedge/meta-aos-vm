VIRTUAL-RUNTIME_dev_manager ?= "busybox-mdev"

PACKAGE_INSTALL = "initramfs-framework-base busybox packagegroup-selinux-minimal policycoreutils-hll policycoreutils-loadpolicy"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
