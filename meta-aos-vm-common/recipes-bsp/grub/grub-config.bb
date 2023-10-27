DESCRIPTION = "Generate grub configuration"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"


inherit deploy

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_install[noexec] = "1"

# Variables
AOS_INITRAMFS_BOOT_PARAMS = " \
    vardir.disk=/dev/${AOS_IMAGE_DISK}5 \
    opendisk.target=/dev/${AOS_IMAGE_DISK}6 opendisk.pkcs11=softhsm opendisk.pkcs11.pinfile=/var/aos/iam/.usrpin \
    aosupdate.disk=/dev/aosvg/workdirs aosupdate.path=um/update_rootfs \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'aosupdate.selinux_module=/usr/share/selinux/aos/base.pp', '', d)} \
"

do_deploy() {
    install -d ${DEPLOYDIR}

    > ${DEPLOYDIR}/grub.cfg

    echo "serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1" >> ${DEPLOYDIR}/grub.cfg
    echo "default=boot" >> ${DEPLOYDIR}/grub.cfg
    echo "timeout=5" >> ${DEPLOYDIR}/grub.cfg
    echo "menuentry 'boot' {" >> ${DEPLOYDIR}/grub.cfg
    echo -n "linux /${KERNEL_IMAGETYPE} " >> ${DEPLOYDIR}/grub.cfg
    echo -n "root=/dev/${AOS_IMAGE_DISK}3 rootwait ro rootfstype=ext4 console=ttyS0 console=tty0 " >> ${DEPLOYDIR}/grub.cfg
    echo "${AOS_INITRAMFS_BOOT_PARAMS}" >> ${DEPLOYDIR}/grub.cfg
    echo "initrd /aos-image-initramfs-${MACHINE}.cpio.gz" >> ${DEPLOYDIR}/grub.cfg
    echo "}" >> ${DEPLOYDIR}/grub.cfg
}

addtask deploy before do_build after do_compile 
