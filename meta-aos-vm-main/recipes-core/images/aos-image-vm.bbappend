# AOS packages
IMAGE_INSTALL_append = " \
    aos-communicationmanager \
    aos-iamanager \
    aos-servicemanager \
    aos-updatemanager \
    aos-vis \
    aos-deprov \
"

ROOTFS_POSTPROCESS_COMMAND_append += "set_board_model;"

set_board_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${BOARD_MODEL}" > ${IMAGE_ROOTFS}/etc/aos/board_model
}
