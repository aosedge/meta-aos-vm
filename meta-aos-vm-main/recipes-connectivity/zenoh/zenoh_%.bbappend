FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add a user agent to avoid 403 errors from crates.io when fetching dependencies.
FETCHCMD_wget = "wget --user-agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64)'"

SRC_URI += " \
    file://zenohd.json5 \
"

do_install:append() {
    install -d 755 ${D}${sysconfdir}/zenohd
    install -m 644 ${WORKDIR}/zenohd.json5 ${D}${sysconfdir}/zenohd
}
