VIRTUAL-RUNTIME_dev_manager ?= "busybox-mdev"

PACKAGE_INSTALL = "initramfs-framework-base busybox"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
