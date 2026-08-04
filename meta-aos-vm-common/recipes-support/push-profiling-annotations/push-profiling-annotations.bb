SUMMARY = "Push journal profiling lines to VictoriaMetrics as annotations"
DESCRIPTION = "Installs push_profiling_annotations.py into /home/root for VM profiling workflows."

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://push_profiling_annotations.py"

S = "${WORKDIR}"

RDEPENDS:${PN} = "python3"

do_install() {
    install -d ${D}/home/root
    # Preserve executable bits from the source script (rwxrwxr-x)
    install -m 0775 ${WORKDIR}/push_profiling_annotations.py ${D}/home/root/push_profiling_annotations.py
}

FILES:${PN} = "/home/root/push_profiling_annotations.py"
