FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://ipforwarding.conf \
"

# Base layer for services
RDEPENDS_${PN} += "\
    python3 \
    python3-core \
"

do_install_append() {
    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d
}

pkg_postinst_${PN}() {
}

python do_update_config() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_servicemanager.cfg")

    with open(file_name) as f:
        data = json.load(f)

    node_id = d.getVar("NODE_ID")
    main_node_id = d.getVar("MAIN_NODE_ID")

    # Update IAM servers

    data["IAMProtectedServerURL"] = node_id+":8089"
    data["IAMPublicServerURL"] = node_id+":8090"

    # Update CM server

    data["CMServerURL"] = main_node_id+":8093"

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
