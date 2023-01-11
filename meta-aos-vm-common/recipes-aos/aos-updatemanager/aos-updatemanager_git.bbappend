FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-reboot.service \
    file://aos-dirs-service.conf \
    file://reboot-on-failure.conf \
"

AOS_UM_UPDATE_MODULES = " \
    updatemodules/overlaysystemd \
    updatemodules/efidualpart \
"

inherit systemd

RDEPENDS_${PN} += " \
    efibootmgr \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/aos-updatemanager.service.d/ \
    ${systemd_system_unitdir} \
"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}${sysconfdir}/systemd/system/aos-updatemanager.service.d
    install -m 0644 ${WORKDIR}/aos-dirs-service.conf ${D}${sysconfdir}/systemd/system/aos-updatemanager.service.d/20-aos-dirs-service.conf
    install -m 0644 ${WORKDIR}/reboot-on-failure.conf ${D}${sysconfdir}/systemd/system/aos-updatemanager.service.d/20-reboot-on-failure.conf
}

python do_update_config() {
    import json

    file_name_source = oe.path.join(d.getVar("WORKDIR"), "aos_updatemanager.cfg")
    file_name_dest = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_updatemanager.cfg")

    with open(file_name_source) as f:
        data = json.load(f)

    node_id = d.getVar("NODE_ID")
    main_node_id = d.getVar("MAIN_NODE_ID")
 
    # Update IAM servers
    
    data["IAMPublicServerURL"] = node_id+":8090"

    # Update CM server

    data["CMServerURL"] = main_node_id+":8091"

    # Update component IDs

    for update_module in data["UpdateModules"]:
        update_module["ID"] = d.getVar("UNIT_MODEL")+"-"+d.getVar("UNIT_VERSION")+"-"+node_id+"-"+update_module["ID"]

    with open(file_name_dest, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
