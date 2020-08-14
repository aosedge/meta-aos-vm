
FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SRCREV = "54c53b10d33275a0cbd900a83fe4ee131b646362"
SRC_URI = " \
    git://github.com/opencontainers/runc;branch=master \
    file://0001-Respect-go-static-flags.patch \
"

RUNC_VERSION = "1.0.0-rc92"
