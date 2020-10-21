SUMMARY = "An image which contains AOS components"

IMAGE_INSTALL = "packagegroup-core-boot kernel-modules ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "
IMAGE_FSTYPES = "tar.bz2 wic.vmdk"
LICENSE = "MIT"

inherit core-image
inherit extrausers

IMAGE_FEATURES_append = " read-only-rootfs"

# Set password to the root user. This is the requirement of the provisioning script.
EXTRA_USERS_PARAMS = "usermod -P Password1 root;"

# AOS packages
IMAGE_INSTALL_append = " \
    aos-servicemanager \
    aos-updatemanager \
    aos-certificatemanager \
    aos-vis \
    openssl-bin \
"

# System packages
IMAGE_INSTALL_append = " \
    mc \
    netconfig \
    openssh \
    tzdata \
"
