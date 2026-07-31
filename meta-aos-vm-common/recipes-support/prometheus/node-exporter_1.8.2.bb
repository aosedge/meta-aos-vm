SUMMARY = "Prometheus exporter for hardware and OS metrics"
HOMEPAGE = "https://github.com/prometheus/node_exporter"
DESCRIPTION = "Prometheus node_exporter exposes hardware and OS metrics collected from *NIX kernels."

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

GO_IMPORT = "github.com/prometheus/node_exporter"
GO_INSTALL = "${GO_IMPORT}"

SRC_URI = " \
    git://${GO_IMPORT}.git;protocol=https;nobranch=1 \
    file://node-exporter.service \
"

SRCREV = "f1e0e8360aa60b6cb5e5cc1560bed348fc2c1895"

inherit go-mod systemd

# Avoid shared Go runtime linking issues with Prometheus binaries
GO_LINKSHARED = ""

export GOPROXY = "https://proxy.golang.org,direct"

# Module downloads happen during compile with go-mod
do_compile[network] = "1"

SYSTEMD_SERVICE:${PN} = "node-exporter.service"

# go.bbclass packs sources into ${PN}-dev; drop non-Linux helper scripts that
# trip file-rdeps QA (bash/ksh) and declare bash for any remaining scripts.
RDEPENDS:${PN}-dev += "bash"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/node-exporter.service ${D}${systemd_system_unitdir}/

    rm -f ${D}${libdir}/go/src/${GO_IMPORT}/test_image.sh
    rm -rf ${D}${libdir}/go/src/${GO_IMPORT}/examples/openbsd-rc.d
}

FILES:${PN} += "${systemd_system_unitdir}"
