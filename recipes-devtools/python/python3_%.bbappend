FILES_${PN} += "${bindir}/python"

do_install_append_class-target() {
      ln -sf ${D}${bindir}/python3 ${D}${bindir}/python
}