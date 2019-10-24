FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos-vis.service \
    file://visconfig.json \
"

AOS_VIS_PLUGINS ?= "\
    storageadapter \
    telemetryemulatoradapter \
    renesassimulatoradapter \
"

PLUGINS = "${AOS_VIS_PLUGINS}"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-vis.service"

HOST_CC_ARCH = ""

FILES_${PN} += " \
    ${systemd_system_unitdir}/aos-vis.service \
    /var/aos/vis/data/*.pem \
    /var/aos/vis/visconfig.json \
"

RDEPENDS_${PN} += "\
    ${@bb.utils.contains('AOS_VIS_PLUGINS', 'telemetryemulatoradapter', 'telemetry-emulator', '', d)} \
"

python do_configure_adapters() {
    import json

    file_name = d.getVar("D")+"/var/aos/vis/visconfig.json"

    with open(file_name) as f:
        data = json.load(f)

    for i, adapter_data in enumerate(data['Adapters']):
        adapter_name = os.path.splitext(os.path.basename(adapter_data['Plugin']))[0]
        if not adapter_name in d.getVar("PLUGINS").split():
            del data['Adapters'][i]

    print(json.dumps(data, indent=4))

    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)
}

do_install_append() {
    if "${@bb.utils.contains('PLUGINS', 'telemetryemulatoradapter', 'true', 'false', d)}"; then
        if ! grep -q 'network-online.target telemetry-emulator.service' ${WORKDIR}/aos-vis.service ; then
            sed -i -e 's/network-online.target/network-online.target telemetry-emulator.service/g' ${WORKDIR}/aos-vis.service
        fi

        if ! grep -q 'ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service ; then
            sed -i -e '/ExecStart/i ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service
        fi
    fi

    install -d ${D}/var/aos/vis
    install -m 0644 ${WORKDIR}/visconfig.json ${D}/var/aos/vis/visconfig.json

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-vis.service ${D}${systemd_system_unitdir}/aos-vis.service

    install -d ${D}/var/aos/vis/data
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}/var/aos/vis/data
}

addtask configure_adapters after do_install before do_populate_sysroot
