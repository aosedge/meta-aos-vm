FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

XDG_RUNTIME_DIR="/run/display"
WESTON_SOCKET_GROUP="weston-display"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "--system ${WESTON_SOCKET_GROUP};"

do_install_append() {
	sed -i 's,@XDG_RUNTIME_DIR@,${XDG_RUNTIME_DIR},g' ${D}${bindir}/weston-start
	sed -i 's,@WESTON_SOCKET_GROUP@,${WESTON_SOCKET_GROUP},g' ${D}${bindir}/weston-start
}

