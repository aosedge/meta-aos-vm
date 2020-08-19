FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-updatemanager.service \
    file://aos_updatemanager.cfg \
"

AOS_UM_PLUGINS ?= "\
    sshmodule \
    testmodule \
    filemodule \
"

inherit systemd

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_updatemanager.cfg \
    ${systemd_system_unitdir}/aos-updatemanager.service \
    /var/aos/updatemanager/crypt/*.pem \
"

do_prepare_modules() {
    file="${S}/src/${GO_IMPORT}/updatemodules/modules.go"

    echo 'package plugins' > ${file}
    echo 'import (' >> ${file}

    for plugin in ${AOS_UM_PLUGINS}; do
        echo "\t_ \"aos_updatemanager/updatemodules/${plugin}\"" >> ${file}
    done

    echo ')' >> ${file}
}

python do_configure_modules() {
    import json

    file_name = d.getVar("D")+"/etc/aos/aos_updatemanager.cfg"

    with open(file_name) as f:
        data = json.load(f)

    newModules = []

    for module in data['UpdateModules']:
        if module['Plugin'] in d.getVar("AOS_UM_PLUGINS").split():
            newModules.append(module)

    data['UpdateModules'] = newModules

    print(json.dumps(data, indent=4))

    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)
}

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service

    install -d ${D}/var/aos/updatemanager/crypt
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}/var/aos/updatemanager/crypt
}

addtask configure_modules after do_install before do_populate_sysroot
addtask prepare_modules after do_unpack before do_compile
