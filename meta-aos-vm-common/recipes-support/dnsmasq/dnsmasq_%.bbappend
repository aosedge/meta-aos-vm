# disable dnsmasq daemon and install binary only

do_install () {
	oe_runmake "PREFIX=${D}${prefix}" \
               "BINDIR=${D}${bindir}" \
               "MANDIR=${D}${mandir}" \
               install
}

SYSTEMD_SERVICE:${PN} = ""
SYSTEMD_AUTO_ENABLE ?= "disable"
