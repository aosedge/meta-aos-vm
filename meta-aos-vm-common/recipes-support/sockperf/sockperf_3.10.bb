SUMMARY = "Network benchmarking utility over socket API"
DESCRIPTION = "sockperf is a network benchmarking utility over socket API. It \
measures the latency of a ping-pong request/response test and reports it as \
percentiles, which keeps the tail of the distribution visible instead of \
hiding it behind an average."
HOMEPAGE = "https://github.com/Mellanox/sockperf"
SECTION = "console/network"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://copying;md5=b4563b57c98bc23c8cecbc0b6d9546e9"

SRC_URI = "git://github.com/Mellanox/sockperf.git;protocol=https;branch=sockperf_v2"
SRCREV = "3c65ad99cd385e18f8a2a655c19826e81a4d17e8"

S = "${WORKDIR}/git"

inherit autotools

do_configure:prepend() {
    mkdir -p ${S}/build ${S}/config/m4 ${S}/config/aux
    echo "${PV}" > ${S}/build/current-version
    echo "${SRCREV}" >> ${S}/build/current-version
}
