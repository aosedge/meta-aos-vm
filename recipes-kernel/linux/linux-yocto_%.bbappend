FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://enable_quota.cfg \
    file://enable_bridge.cfg \
    file://enable_cgroups.cfg \
    file://enable_overlay.cfg \
    file://iptables.cfg \
    file://enable_tpm.cfg \
    file://enable_squashfs.cfg \
"
