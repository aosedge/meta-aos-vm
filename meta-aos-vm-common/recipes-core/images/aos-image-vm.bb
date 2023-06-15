SUMMARY = "An image which contains AOS components"
LICENSE = "Apache-2.0"

IMAGE_LINGUAS = " "

require recipes-core/images/aos-image.inc

inherit core-image extrausers

IMAGE_INSTALL = "packagegroup-core-boot kernel-modules ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_FSTYPES = "tar.bz2 wic.vmdk"

IMAGE_FEATURES:append = " read-only-rootfs"

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
"

IMAGE_DISK ?= "sda"

# Variables
INITRAMFS_BOOT_PARAMS = " \
    vardir.disk=/dev/${IMAGE_DISK}5 opendisk.target=/dev/${IMAGE_DISK}6 opendisk.pkcs11=softhsm \
    opendisk.pkcs11.pinfile=/var/aos/iam/.usrpin aosupdate.disk=/dev/aosvg/workdirs aosupdate.path=um/update_rootfs \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'selinux.module=/usr/share/selinux/aos/base.pp', '', d)} \
"

# In case of usage exclude directive in wks.in file, bitbake
# tries to copy files without SELinux labeling savings, so avoid using
# it with enabled SELinux.
ROOTFS_EXCLUDE_PATHS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '', '--exclude-path ./var/ ./home/', d)}"
