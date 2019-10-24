SUMMARY = "An image which contains AOS components"

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "
IMAGE_FSTYPES = "wic.vmdk"
LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

# AOS packages
IMAGE_INSTALL_append = " \
    aos-vis \
"

# System packages
IMAGE_INSTALL_append = " \
    netconfig \
    openssh \
    tzdata \
"
