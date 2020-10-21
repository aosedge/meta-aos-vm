# Use our initrd script instead of Yocto`s.

FILESEXTRAPATHS_prepend := "${THISDIR}/initramfs-framework:"
SRC_URI += " file://finish"
