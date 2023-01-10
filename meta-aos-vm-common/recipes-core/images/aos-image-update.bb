SUMMARY = "Target to generate AOS update bundle"
LICENSE = "Apache-2.0"

# Variables

AOS_BASE_IMAGE = "aos-image-vm"

BUNDLE_BOOT_ID = "${UNIT_MODEL}-${UNIT_VERSION}-${NODE_ID}-boot"
BUNDLE_ROOTFS_ID = "${UNIT_MODEL}-${UNIT_VERSION}-${NODE_ID}-rootfs"

BUNDLE_BOOT_DESC = "boot image"
BUNDLE_ROOTFS_DESC = "rootfs image"

BUNDLE_BOOT ?= "1"
BUNDLE_ROOTFS ?= "full"

# Inherit

inherit rootfs-image-generator part-image-generator metadata-generator bundle-generator

# Dependencies

do_create_bundle[depends] = "${AOS_BASE_IMAGE}:do_create_shared_links"
do_create_bundle[cleandirs] = "${BUNDLE_WORK_DIR}"

# Configure part-image-generator

PART_IMAGE_DIR = "${BUNDLE_WORK_DIR}"
PART_IMAGE_FILE = "${IMAGE_BASENAME}-${MACHINE}-${BOOT_IMAGE_VERSION}.boot.gz"
PART_IMAGE_PARTNO = "${@ "1" if bb.utils.to_boolean(d.getVar('BUNDLE_BOOT')) else "" }"
PART_SOURCE_DIR =  "${TMPDIR}/work-shared/${IMAGE_BASENAME}-${MACHINE}/build-wic"

# Configure rootfs-image-generator

ROOTFS_IMAGE_DIR = "${BUNDLE_WORK_DIR}"
ROOTFS_IMAGE_FILE = "${IMAGE_BASENAME}-${MACHINE}-${ROOTFS_IMAGE_VERSION}.rootfs.squashfs"
ROOTFS_IMAGE_TYPE = "${BUNDLE_ROOTFS}"
ROOTFS_SOURCE_DIR =  "${TMPDIR}/work-shared/${IMAGE_BASENAME}-${MACHINE}/rootfs"
ROOTFS_OSTREE_REPO = "${BUNDLE_OSTREE_REPO}/${NODE_ID}"

# Configure bundle-generator

BUNDLE_DIR ?= "${DEPLOY_DIR}/update"
BUNDLE_FILE ?= "${UNIT_MODEL}-${UNIT_VERSION}-${NODE_ID}-${BUNDLE_IMAGE_VERSION}.tar"

# Tasks

python do_create_metadata() {
    components_metadata = []

    d.setVar("BUNDLE_IMAGE_FILES", "")

    if d.getVar("BUNDLE_ROOTFS") and d.getVar("BUNDLE_ROOTFS") != "none":
        install_dep = {}
        annotations = {"type": "full"}

        if d.getVar("BUNDLE_ROOTFS") == "incremental":
            install_dep = create_dep(d.getVar("BUNDLE_ROOTFS_ID"), d.getVar("ROOTFS_REF_VERSION"))
            annotations = {"type": "incremental"}

        components_metadata.append(create_component_metadata(d.getVar("BUNDLE_ROOTFS_ID"), d.getVar("ROOTFS_IMAGE_FILE"),
            d.getVar("ROOTFS_IMAGE_VERSION"), d.getVar("BUNDLE_ROOTFS_DESC"), install_dep, None, annotations))

    if bb.utils.to_boolean(d.getVar("BUNDLE_BOOT")):
        components_metadata.append(create_component_metadata(d.getVar("BUNDLE_BOOT_ID"), d.getVar("PART_IMAGE_FILE"),
            d.getVar("BOOT_IMAGE_VERSION"), d.getVar("BUNDLE_BOOT_DESC")))

    write_image_metadata(d.getVar("BUNDLE_WORK_DIR"), components_metadata)
}

fakeroot python do_create_bundle() {
    if (not d.getVar("BUNDLE_ROOTFS") or d.getVar("BUNDLE_ROOTFS") == "none") and (not bb.utils.to_boolean(d.getVar("BUNDLE_BOOT"))):
       return

    bb.build.exec_func("do_create_metadata", d)
    bb.build.exec_func("do_create_rootfs_image", d)
    bb.build.exec_func("do_create_part_image", d)
    bb.build.exec_func("do_pack_bundle", d)
}

addtask create_bundle after do_compile before do_build
