FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-updatemanager.service \
    file://aos_updatemanager.cfg \
"

AOS_UM_PLUGINS ?= "\
    sshmodule \
    testmodule \
"

PLUGINS = "${AOS_UM_PLUGINS}"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-updatemanager.service"

HOST_CC_ARCH = ""

FILES_${PN} += " \
    ${systemd_system_unitdir}/aos-updatemanager.service \
    /var/aos/updatemanager/data/*.pem \
    /var/aos/updatemanager/aos_updatemanager.cfg \
"

python do_configure_modules() {
    import json

    file_name = d.getVar("D")+"/var/aos/updatemanager/aos_updatemanager.cfg"

    with open(file_name) as f:
        data = json.load(f)

    for i, adapter_data in enumerate(data['Modules']):
        adapter_name = os.path.splitext(os.path.basename(adapter_data['Plugin']))[0]
        if not adapter_name in d.getVar("PLUGINS").split():
            del data['Modules'][i]

    print(json.dumps(data, indent=4))

    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)
}

do_install_append() {
    install -d ${D}/var/aos/updatemanager
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}/var/aos/updatemanager/aos_updatemanager.cfg

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service

    install -d ${D}/var/aos/updatemanager/data
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}/var/aos/updatemanager/data
}

addtask configure_modules after do_install before do_populate_sysroot
