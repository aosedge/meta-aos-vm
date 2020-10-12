FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "git://git@gitpct.epam.com/epmd-aepr/${GO_IMPORT}.git;branch=mr_movefromum;protocol=ssh"

SRC_URI_append = "\
    file://aos-certificatemanager.service \
    file://aos_certificatemanager.cfg \
"

AOS_CM_PLUGINS ?= "\
    swmodule \
"

inherit systemd

FILES_${PN} += " \
    ${sysconfdir}/aos/aos_certificatemanager.cfg \
    ${systemd_system_unitdir}/aos-certificatemanager.service \
"

do_prepare_modules() {
    file="${S}/src/${GO_IMPORT}/certmodules/modules.go"

    echo 'package plugins' > ${file}
    echo 'import (' >> ${file}

    for plugin in ${AOS_CM_PLUGINS}; do
        echo "\t_ \"aos_certificatemanager/certmodules/${plugin}\"" >> ${file}
    done

    echo ')' >> ${file}
}

python do_configure_modules() {
    import json

    file_name = d.getVar("D")+"/etc/aos/aos_certificatemanager.cfg"

    with open(file_name) as f:
        data = json.load(f)

    newModules = []

    for module in data['CertModules']:
        if module['Plugin'] in d.getVar("AOS_CM_PLUGINS").split():
            newModules.append(module)

    data['CertModules'] = newModules

    print(json.dumps(data, indent=4))

    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)
}

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_certificatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-certificatemanager.service ${D}${systemd_system_unitdir}/aos-certificatemanager.service

    install -d ${D}/var/aos/certificatemanager
}

addtask configure_modules after do_install before do_populate_sysroot
addtask prepare_modules after do_unpack before do_compile
