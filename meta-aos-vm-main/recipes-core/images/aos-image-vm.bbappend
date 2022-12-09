# AOS packages
IMAGE_INSTALL_append = " \
    aos-communicationmanager \
    aos-iamanager \
    aos-servicemanager \
    aos-updatemanager \
    aos-vis \
    aos-deprov \
"

ROOTFS_POSTPROCESS_COMMAND_append += "set_unit_model;"

set_unit_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${UNIT_MODEL}" > ${IMAGE_ROOTFS}/etc/aos/unit_model
}
