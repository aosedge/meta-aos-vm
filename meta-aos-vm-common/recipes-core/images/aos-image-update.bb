SUMMARY = "Target to generate AOS update bundle"
LICENSE = "Apache-2.0"

# Variables

AOS_BASE_IMAGE = "aos-image-vm"

AOS_BUNDLE_BOOT_ID = "${AOS_UNIT_MODEL}-${AOS_UNIT_VERSION}-${AOS_NODE_ID}-boot"
AOS_BUNDLE_ROOTFS_ID = "${AOS_UNIT_MODEL}-${AOS_UNIT_VERSION}-${AOS_NODE_ID}-rootfs"

AOS_BUNDLE_BOOT_DESC = "boot image"
AOS_BUNDLE_ROOTFS_DESC = "rootfs image"

AOS_BUNDLE_BOOT ?= "1"
AOS_BUNDLE_ROOTFS ?= "full"

# Inherit

inherit rootfs-image-generator part-image-generator metadata-generator bundle-generator

# Dependencies

do_create_bundle[depends] = "${AOS_BASE_IMAGE}:do_create_shared_links"
do_create_bundle[cleandirs] = "${AOS_BUNDLE_WORK_DIR}"

# Configure part-image-generator

AOS_PART_IMAGE_DIR = "${AOS_BUNDLE_WORK_DIR}"
AOS_PART_IMAGE_FILE = "${IMAGE_BASENAME}-${MACHINE}-${AOS_BOOT_IMAGE_VERSION}.boot.gz"
AOS_PART_IMAGE_PARTNO = "${@ "1" if bb.utils.to_boolean(d.getVar('AOS_BUNDLE_BOOT')) else "" }"
AOS_PART_SOURCE_DIR =  "${TMPDIR}/work-shared/${IMAGE_BASENAME}-${MACHINE}/build-wic"

# Configure rootfs-image-generator

AOS_ROOTFS_IMAGE_DIR = "${AOS_BUNDLE_WORK_DIR}"
AOS_ROOTFS_IMAGE_FILE = "${IMAGE_BASENAME}-${MACHINE}-${AOS_ROOTFS_IMAGE_VERSION}.rootfs.squashfs"
AOS_ROOTFS_IMAGE_TYPE = "${AOS_BUNDLE_ROOTFS}"
AOS_ROOTFS_SOURCE_DIR =  "${TMPDIR}/work-shared/${IMAGE_BASENAME}-${MACHINE}/rootfs"
AOS_ROOTFS_OSTREE_REPO = "${AOS_BUNDLE_OSTREE_REPO}/${AOS_NODE_ID}"

# Configure bundle-generator

AOS_BUNDLE_DIR ?= "${DEPLOY_DIR}/update"
AOS_BUNDLE_FILE ?= "${AOS_UNIT_MODEL}-${AOS_UNIT_VERSION}-${AOS_NODE_ID}-${AOS_BUNDLE_IMAGE_VERSION}.tar"

# Tasks

python do_create_metadata() {
    components_metadata = []

    if d.getVar("AOS_BUNDLE_ROOTFS") and d.getVar("AOS_BUNDLE_ROOTFS") != "none":
        install_dep = {}
        annotations = {"type": "full"}

        if d.getVar("AOS_BUNDLE_ROOTFS") == "incremental":
            install_dep = create_dep(d.getVar("AOS_BUNDLE_ROOTFS_ID"), d.getVar("AOS_ROOTFS_REF_VERSION"))
            annotations = {"type": "incremental"}

        components_metadata.append(create_component_metadata(d.getVar("AOS_BUNDLE_ROOTFS_ID"), d.getVar("AOS_ROOTFS_IMAGE_FILE"),
            d.getVar("AOS_ROOTFS_IMAGE_VERSION"), d.getVar("AOS_BUNDLE_ROOTFS_DESC"), install_dep, None, annotations))

    if bb.utils.to_boolean(d.getVar("AOS_BUNDLE_BOOT")):
        components_metadata.append(create_component_metadata(d.getVar("AOS_BUNDLE_BOOT_ID"), d.getVar("AOS_PART_IMAGE_FILE"),
            d.getVar("AOS_BOOT_IMAGE_VERSION"), d.getVar("AOS_BUNDLE_BOOT_DESC")))

    write_image_metadata(d.getVar("AOS_BUNDLE_WORK_DIR"), components_metadata)
}

fakeroot python do_create_bundle() {
    if (not d.getVar("AOS_BUNDLE_ROOTFS") or d.getVar("AOS_BUNDLE_ROOTFS") == "none") and (not bb.utils.to_boolean(d.getVar("AOS_BUNDLE_BOOT"))):
       return

    bb.build.exec_func("do_create_metadata", d)
    bb.build.exec_func("do_create_rootfs_image", d)
    bb.build.exec_func("do_create_part_image", d)
    bb.build.exec_func("do_pack_bundle", d)
}

addtask create_bundle after do_compile before do_build
