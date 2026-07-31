SUMMARY = "Prometheus exporter that reports metrics on selected processes"
HOMEPAGE = "https://github.com/ncabatoff/process-exporter"
DESCRIPTION = "Prometheus process-exporter mines /proc to report resource usage for selected process groups."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=8748f01be17d4b2ce4421ce67a12c479"

GO_IMPORT = "github.com/ncabatoff/process-exporter"
GO_INSTALL = "${GO_IMPORT}/cmd/process-exporter"

SRC_URI = " \
    git://${GO_IMPORT}.git;protocol=https;nobranch=1 \
    file://process-exporter.service \
    file://all.yaml \
"

SRCREV = "626431b9a759d425bbb78eb15153f892970aadee"

inherit go-mod systemd

# Avoid shared Go runtime linking issues with Prometheus binaries
GO_LINKSHARED = ""

export GOPROXY = "https://proxy.golang.org,direct"

# Module downloads happen during compile with go-mod
do_compile[network] = "1"

SYSTEMD_SERVICE:${PN} = "process-exporter.service"

do_install:append() {
    install -d ${D}${sysconfdir}/process-exporter
    install -m 0644 ${WORKDIR}/all.yaml ${D}${sysconfdir}/process-exporter/all.yaml

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/process-exporter.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += " \
    ${sysconfdir}/process-exporter \
    ${systemd_system_unitdir} \
"
