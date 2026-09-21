FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://common_node.cfg \
    ${@bb.utils.contains('DISTRO_FEATURES', 'benchmark', 'file://benchmark.cfg', '', d)} \
"
