SUMMARY = "Fast, cost-effective monitoring solution and time series database"
HOMEPAGE = "https://victoriametrics.com/"
DESCRIPTION = "VictoriaMetrics single-node TSDB with Prometheus-compatible scraping and querying."

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=fc77103b8aac4974199953396fba3d2f"

GO_IMPORT = "github.com/VictoriaMetrics/VictoriaMetrics"
GO_INSTALL = "${GO_IMPORT}/app/victoria-metrics"

SRC_URI = " \
    git://${GO_IMPORT}.git;protocol=https;nobranch=1 \
    file://victoria-metrics.service \
    file://scrape.yml \
"

SRCREV = "65bb429b813bf1f8d747cb22b1dca9c6dcb4ec07"

inherit go-mod systemd

# Avoid shared Go runtime linking issues
GO_LINKSHARED = ""

# Pure Go build avoids gozstd/CGO cross-compile issues with prebuilt libzstd
export CGO_ENABLED = "0"

GO_EXTRA_LDFLAGS = "-X github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=victoria-metrics-v${PV}"

export GOPROXY = "https://proxy.golang.org,direct"

# Module downloads happen during compile with go-mod
do_compile[network] = "1"

SYSTEMD_SERVICE:${PN} = "victoria-metrics.service"

RDEPENDS:${PN}-dev += "bash"

do_install:append() {
    install -d ${D}${sysconfdir}/victoria-metrics
    install -m 0644 ${WORKDIR}/scrape.yml ${D}${sysconfdir}/victoria-metrics/scrape.yml

    install -d ${D}${localstatedir}/lib/victoria-metrics

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/victoria-metrics.service ${D}${systemd_system_unitdir}/

    # go.bbclass packs sources into ${PN}-dev; prebuilt non-ELF archives from
    # gozstd (Windows/macOS/etc.) break dwarfsrcfiles during do_package.
    find ${D}${libdir}/go/src/${GO_IMPORT}/vendor/github.com/valyala/gozstd \
        -type f \( -name '*.a' -o -name '*.lib' -o -name '*.dll' -o -name '*.dylib' \) \
        -delete 2>/dev/null || true
}

FILES:${PN} += " \
    ${sysconfdir}/victoria-metrics \
    ${localstatedir}/lib/victoria-metrics \
    ${systemd_system_unitdir} \
"

# Storage directory must exist and remain writable on RO rootfs setups that
# mount a separate /var partition.
CONFFILES:${PN} += "${sysconfdir}/victoria-metrics/scrape.yml"
