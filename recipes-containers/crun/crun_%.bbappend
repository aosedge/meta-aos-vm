LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

REQUIRED_DISTRO_FEATURES ?= "systemd"

DEPENDS += "systemd"

SRCREV_crun = "7ef74c9330033cb884507c28fd8c267861486633"
SRCREV_libocispec = "c9b8b9524814550a489aa6d38b2dec95633ffa15"
SRCREV_ispec = "79b036d80240ae530a8de15e1d21c7ab9292c693"
SRCREV_rspec = "7413a7f753e1bd9a6a9c6dc7f96f55888cbbd476"

inherit autotools-brokensep pkgconfig features_check

do_configure_prepend () {
    ./autogen.sh
}
