AOS_IAM_CERT_MODULES = " \
    certhandler/modules/pkcs11module \
"

RDEPENDS_${PN} += " \
    aos-setupdisk \
    softhsm \
"

pkg_postinst_${PN}[noexec] = "1"

python do_update_config() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_iamanager.cfg")

    with open(file_name) as f:
        data = json.load(f)

    # Set node ID and node type
    
    node_info = {
        "NodeID": d.getVar("NODE_ID"),
        "NodeType" : d.getVar("NODE_TYPE")
    }

    data = {**node_info, **data}

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
