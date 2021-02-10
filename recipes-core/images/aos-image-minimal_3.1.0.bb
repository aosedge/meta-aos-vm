SUMMARY = "An image which contains AOS components"

IMAGE_INSTALL = "packagegroup-core-boot kernel-modules ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "
IMAGE_FSTYPES = "tar.bz2 wic.vmdk"
LICENSE = "MIT"

inherit core-image
inherit extrausers

IMAGE_FEATURES_append = " read-only-rootfs"

# Set password to the root user. This is the requirement of the provisioning script.
EXTRA_USERS_PARAMS = "usermod -P Password1 -s /bin/bash root;"

# AOS packages
IMAGE_INSTALL_append = " \
    aos-servicemanager \
    aos-updatemanager \
    aos-iamanager \
    aos-vis \
    openssl-bin \
    efibootmgr \
    iperf3 \
"

# System packages
IMAGE_INSTALL_append = " \
    bash \
    mc \
    netconfig \
    openssh \
    tzdata \
"

################################################################################
# Update bundle generation
################################################################################

# Configuration

BOARD_MODEL ?= "vm-dev;1.0"

BUNDLE_ROOTFS ?= "none"
BUNDLE_BOOT ?= "0"

ROOTFS_REF_VERSION ?= "${PV}"

BOARD_ROOTFS_VERSION ?= "${PV}"
BOARD_BOOT_VERSION ?= "${PV}"

# Inherit

inherit metadata-generator

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://bundle-aos.cfg \
    file://bundle_templates \
"

python () {
    d.delVarFlag("do_fetch", "noexec")
    d.delVarFlag("do_unpack", "noexec")
}

# Variables

BUNDLES_DIR ?= "${DEPLOY_DIR_IMAGE}/bundles"

BUILD_WIC_DIR="${WORKDIR}/build-wic"

BUNDLE_CONFIG_PATH = "${WORKDIR}/bundle-aos.cfg"
BUNDLE_WORK_DIR = "${WORKDIR}/bundle"

BUNDLE_BOOT_FILE = "${IMAGE_BASENAME}-${MACHINE}-${BOARD_BOOT_VERSION}.boot.gz"
BUNDLE_ROOTFS_FILE = "${IMAGE_BASENAME}-${MACHINE}-${BOARD_ROOTFS_VERSION}.rootfs.squashfs"

BUNDLE_BOOT_ID = "boot"
BUNDLE_ROOTFS_ID = "rootfs"

OSTREE_REPO_PATH ?= "${BUNDLES_DIR}/repo"
OSTREE_REPO_TYPE = "archive"

SHARED_ROOTFS_LINK = "${TMPDIR}/work-shared/${MACHINE}/${PN}-rootfs"
ROOTFS_TAR = "${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete/${IMAGE_LINK_NAME}.tar.bz2"
ROOTFS_DIFF_DIR = "${WORKDIR}/rootfs_diff"

ROOTFS_REMOVE_DIRS = "var home"

# Dependencies

do_create_bundle[vardeps] += "BUNDLE_BOOT BUNDLE_ROOTFS ROOTFS_REF_VERSION"

DEPENDS_append = " ostree-native squashfs-tools-native"

# Tasks

pack_bundle() {
    mkdir -p ${BUNDLES_DIR}
    tar cf ${BUNDLES_DIR}/${IMAGE_BASENAME}-${MACHINE}-${PV}.bundle.tar -C ${BUNDLE_WORK_DIR}/ .
}

create_part_gz() {
    l_bundle_path=$1
    l_output_file=$2
    l_part=$3

    mkdir -p ${l_bundle_path}
    part_file=$(find ${WORKDIR}/build-wic -name "*direct.${l_part}")
    gzip -c ${part_file} > "${l_bundle_path}/${l_output_file}"
}

create_boot_update() {
    create_part_gz ${BUNDLE_WORK_DIR} ${BUNDLE_BOOT_FILE} "p1"
}

create_rootfs_full_update() {
    mksquashfs ${IMAGE_ROOTFS} ${BUNDLE_WORK_DIR}/${BUNDLE_ROOTFS_FILE} -e ${ROOTFS_REMOVE_DIRS}
}

init_ostree_repo() {
    if [ ! -d ${OSTREE_REPO_PATH}/refs ]; then
        echo "Ostree repo doesn't exist. Create ostree repo"

        mkdir -p $(dirname "${OSTREE_REPO_PATH}")
        ostree --repo=${OSTREE_REPO_PATH} init --mode=${OSTREE_REPO_TYPE}
    fi
}

ostree_commit() {
    ostree --repo=${OSTREE_REPO_PATH} commit \
           --tree=tar=${ROOTFS_TAR} \
           --skip-if-unchanged \
           --branch=${BOARD_ROOTFS_VERSION} \
           --subject="${BOARD_ROOTFS_VERSION}-${DATATIME}"
}

create_rootfs_incremental_update() {
    rm -rf ${ROOTFS_DIFF_DIR}
    mkdir -p ${ROOTFS_DIFF_DIR}

    ostree --repo=${OSTREE_REPO_PATH} diff ${ROOTFS_REF_VERSION} ${BOARD_ROOTFS_VERSION} |
    while read -r item; do
        action=${item%% *}
        item=${item##* }

        if [ ${action} = "A" ] || [ ${action} = "M" ]; then
            if [ -d ${WORKDIR}/rootfs${item} ]; then
                mkdir -p ${ROOTFS_DIFF_DIR}${item}
            else
                mkdir -p $(dirname ${ROOTFS_DIFF_DIR}${item})
                cp -a ${WORKDIR}/rootfs${item} ${ROOTFS_DIFF_DIR}${item}
            fi
        elif [ ${action} = "D" ]; then
            mkdir -p $(dirname ${ROOTFS_DIFF_DIR}${item})
            mknod ${ROOTFS_DIFF_DIR}${item} c 0 0 
        fi
    done

    if [ ! "$(ls -A ${ROOTFS_DIFF_DIR})" ]; then
        bbwarn "incremental roofs update is empty"
    fi

    mksquashfs ${ROOTFS_DIFF_DIR} ${BUNDLE_WORK_DIR}/${BUNDLE_ROOTFS_FILE} -e ${ROOTFS_REMOVE_DIRS}
}

fakeroot python do_create_bundle() {
    import configparser
    import shutil
    import os

    def override_config(d, cfg):
        cfg["bundleConfig"]["workspaceBaseDir"] = d.getVar("WORKDIR")
        cfg["bundleConfig"]["boardModel"] = d.getVar("BOARD_MODEL")

        components = ""

        bundle_boot = d.getVar("BUNDLE_BOOT")
        boot_id = d.getVar("BUNDLE_BOOT_ID")

        if bundle_boot == "1":
            components += " "+boot_id
            cfg[boot_id]["fileName"] = os.path.join(".", d.getVar("BUNDLE_BOOT_FILE"))
            cfg[boot_id]["vendorVersion"] = d.getVar("BOARD_BOOT_VERSION")
            cfg[boot_id]["type"] = "full"
            
        bundle_rootfs = d.getVar("BUNDLE_ROOTFS")
        rootfs_id = d.getVar("BUNDLE_ROOTFS_ID")

        if bundle_rootfs != "none":
            components += " "+rootfs_id
            cfg[rootfs_id]["fileName"] = os.path.join(".", d.getVar("BUNDLE_ROOTFS_FILE"))
            cfg[rootfs_id]["vendorVersion"] = d.getVar("BOARD_ROOTFS_VERSION")

            if bundle_rootfs == "full" or bundle_rootfs == "incremental":
                cfg[rootfs_id]["type"] = bundle_rootfs
            else:
                bb.fatal("undefined rootfs update type: {}".format(bundle_rootfs))

            if bundle_rootfs == "incremental" and d.getVar("ROOTFS_REF_VERSION") == d.getVar("BOARD_ROOTFS_VERSION"):
                bb.fatal("rootfs ref version should not be equal current version: {}".format(d.getVar("ROOTFS_REF_VERSION")))

        cfg["bundleConfig"]["components"] = components

    cfg = configparser.ConfigParser()

    with open(d.getVar("BUNDLE_CONFIG_PATH")) as f:
        cfg.read_file(f)

    override_config(d, cfg)

    metadata = init_metadata(cfg, d.getVar("BUNDLE_WORK_DIR"))

    components = metadata.get_components()

    if len(components) == 0:
        bb.debug(1, "Skipping bundle generation")
        return

    metadata.write()

    if "boot" in components:
        bb.debug(1, "Generage boot image")
        bb.build.exec_func("create_boot_update", d)

    if "rootfs" in components:
        bb.build.exec_func("init_ostree_repo", d)

        bb.debug(1, "Generage rootfs image")

        bb.build.exec_func("ostree_commit", d)

        if d.getVar("BUNDLE_ROOTFS") == "full":
            bb.build.exec_func("create_rootfs_full_update", d)
        else:
            bb.build.exec_func("create_rootfs_incremental_update", d)

    bb.build.exec_func("pack_bundle", d)
}

do_set_board_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${BOARD_MODEL}" > ${IMAGE_ROOTFS}/etc/aos/board_model
}

do_set_rootfs_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${BOARD_ROOTFS_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

do_update_fstab_on_rootfs() {
    if [ -f ${BUILD_WIC_DIR}/fstab ]; then
        cp -rf ${IMAGE_ROOTFS}/etc/fstab ${BUILD_WIC_DIR}/fstab.orig
        cp -rf ${BUILD_WIC_DIR}/fstab ${IMAGE_ROOTFS}/etc/fstab
    fi
}

# We need to have rootfs in work-shared dir for the layer functionality
# But, according to the manual - IMAGE_ROOTFS variable is not configurable.
# Creating symlink IMAGE_ROOTFS to work-shared to get an access to this rootfs by layers
do_set_rootfs_link() {
    rm -rf ${SHARED_ROOTFS_LINK}
    lnr ${IMAGE_ROOTFS} ${SHARED_ROOTFS_LINK}
}

addtask set_rootfs_link after do_rootfs before do_image_wic do_image_qa
addtask set_board_model after do_rootfs before do_image_qa
addtask set_rootfs_version after do_rootfs before do_image_qa
addtask create_bundle after do_install do_image_tar do_image_squashfs do_image_wic before do_image_complete
addtask update_fstab_on_rootfs after do_image_wic before do_image_tar do_create_bundle
