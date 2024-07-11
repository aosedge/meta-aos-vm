SUMMARY = "An image which contains AOS components"
LICENSE = "Apache-2.0"

IMAGE_LINGUAS = " "

require recipes-core/images/aos-image.inc

inherit core-image extrausers

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_FSTYPES = "ext4"

# Set password to the root user. This is the requirement of the provisioning script.
EXTRA_USERS_PARAMS = "usermod -p '\$6\$1A1UsrSPWS8nQFZP\$dI8sN.4/y00EWaLEN22tWcLtrBKD08hZTitCub4BhEC2qrDZhQF3YKapF3bXLFq0rsj6xhlJehrEHDJfDFcsF/' -s /bin/bash root;"

# System packages
IMAGE_INSTALL:append = " \
    bash \
    iperf3 \
    mc \
    netconfig \
    openssh \
    tzdata \
"

# AOS packages
IMAGE_INSTALL:append = " \
    aos-deprov \
    aos-clearhsm \
"

# Set fixed rootfs size
IMAGE_ROOTFS_SIZE ?= "1048576"
IMAGE_OVERHEAD_FACTOR ?= "1.0"
IMAGE_ROOTFS_EXTRA_SPACE ?= "524288"
