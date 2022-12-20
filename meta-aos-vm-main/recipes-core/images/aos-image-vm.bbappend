# AOS packages
IMAGE_INSTALL_append = " \
    aos-communicationmanager \
    aos-iamanager \
    aos-servicemanager \
    aos-updatemanager \
    aos-provfirewall \
    aos-vis \
    aos-deprov \
"

ROOTFS_POSTPROCESS_COMMAND_append += "set_unit_model;"

set_unit_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${UNIT_MODEL};${UNIT_VERSION}" > ${IMAGE_ROOTFS}/etc/aos/unit_model
}
