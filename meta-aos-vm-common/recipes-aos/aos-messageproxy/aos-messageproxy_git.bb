do_install:append() {
    # Do not install headers files to prevent SDK build conflicts
    rm -rf ${D}${includedir}
}
