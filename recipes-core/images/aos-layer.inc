IMAGE_LINGUAS = " "
LICENSE = "Apache-2.0"

PARENT_IMAGE ?= "aos-image-minimal"
LAYER_VERSION ?= "1"

require aos-image-minimal_3.1.0.bb

IMAGE_FSTYPES = "tar"
LAYER_ROOTFS = "${WORKDIR}/layer_rootfs"
LAYER_BUNDLE_WORKDIR = "${WORKDIR}/layer_bundle_workdir"
LAYER_BUNDLE_DEPLOYDIR = "${DEPLOY_DIR_IMAGE}/layer_bundles"
IMAGE_ROOTFS = "${TMPDIR}/work-shared/${MACHINE}/${PN}-rootfs"
PARENT_IMAGE_ROOTFS = "${TMPDIR}/work-shared/${MACHINE}/${PARENT_IMAGE}-rootfs"
DEPENDS_append = " aos-image-minimal rsync-native"
IMAGE_ROOTFS_TAR = "${IMGDEPLOYDIR}/${PN}-${MACHINE}.tar"
IMAGE_CMD_tar = "${IMAGE_CMD_TAR} --numeric-owner -cf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar -C ${LAYER_ROOTFS} . || [ $? -eq 1 ]"

def get_depends(features):
    import json
    return json.dumps(features.split())

OS_FEATURES = "${@get_depends("${LAYER_FEATURES_${PN}}")}"

generate_json() {
    local json_path="$1"
    local sha_sum="$2"
    local parent_layer_sha="$3"
    local parent_ver="$4"
    local bundle_size="$5"
    layer_name="${PN}"

    cat > ${json_path} << EOF
    {
        "mediaType": "application/vnd.aos.image.layer.v1.tar",
        "size": ${bundle_size},
        "digest": "sha256:${sha_sum}",
        "platform":
        {
            "Architecture": "amd64",
            "OS": "Linux",
            "OSVersion": "${BOARD_DISTRO_VERSION}",
            "OSFeatures": ${OS_FEATURES}
        },
        "annotations":
        {
EOF

    if [ "${parent_layer_sha}" = "empty" ]; then
       cat >> ${json_path} << EOF
           "layerId": "${layer_name}:${LAYER_VERSION}"
EOF
    else
        cat >> ${json_path} << EOF
            "layerId": "${layer_name}:${LAYER_VERSION}",
            "parentLayerId": "${PARENT_IMAGE}:${parent_ver} ",
            "parentLayerDigest":"sha256:${parent_layer_sha}"
EOF
    fi

cat >> ${json_path} << EOF
        }
    }
EOF

}

do_prepare_layer_bundle[depends] = "${@bb.utils.contains('PARENT_IMAGE', 'aos-image-minimal', '', '${PARENT_IMAGE}:do_prepare_layer_bundle', d)}"
do_prepare_layer_bundle[depends] += "${PN}:do_image_tar"
do_prepare_layer_bundle[cleandirs] += "${LAYER_BUNDLE_WORKDIR}"
do_prepare_layer_bundle[dirs] += "${LAYER_BUNDLE_DEPLOYDIR}"

do_prepare_layer_bundle () {
    #Get sha256 from tar
    SHA_SUM="$(sha256sum -b ${IMAGE_ROOTFS_TAR} | cut -d' ' -f1)"

    #Create file in deploy dir name=parent contents=sha256
    echo "${SHA_SUM} ${LAYER_VERSION}" > ${LAYER_BUNDLE_DEPLOYDIR}/${PN}.sha256

    #Copy tar with the new name to WORKDIR
    cp ${IMAGE_ROOTFS_TAR} ${LAYER_BUNDLE_WORKDIR}/${SHA_SUM}

    #Get info from layer_bundles image of parent_layer
    PARENT_SHA_SUM="empty"
    PARENT_VERSION="empty"
    if [ x"${PARENT_IMAGE}" != x"aos-image-minimal" ]; then
        PARENT_SHA_SUM="$(cat ${LAYER_BUNDLE_DEPLOYDIR}/${PARENT_IMAGE}.sha256| cut -d' ' -f1)"
        PARENT_VERSION="$(cat ${LAYER_BUNDLE_DEPLOYDIR}/${PARENT_IMAGE}.sha256| cut -d' ' -f2)"
    fi

    #Generate json
    generate_json "${LAYER_BUNDLE_WORKDIR}/metadata.json" "${SHA_SUM}" "${PARENT_SHA_SUM}" "${PARENT_VERSION}" "$(stat -c%s ${LAYER_BUNDLE_WORKDIR}/${SHA_SUM})"

    #Create tar archieve to layer_bundles deploy dir
    cd ${LAYER_BUNDLE_WORKDIR}
    ${IMAGE_CMD_TAR} --numeric-owner -czf ${LAYER_BUNDLE_DEPLOYDIR}/${PN}-${MACHINE}-bundle.tar.gz .
}

do_prepare_layer[depends] += "${PARENT_IMAGE}:do_rootfs"
do_prepare_layer[cleandirs] = "${LAYER_ROOTFS}"

fakeroot do_prepare_layer () {
    cd ${LAYER_ROOTFS}
    rsync -HAXlrvcm --append --progress --delete --compare-dest=${PARENT_IMAGE_ROOTFS}/ ${IMAGE_ROOTFS}/* .
    find . -type d -empty -delete
}

addtask do_prepare_layer after do_rootfs before do_image_tar
addtask do_prepare_layer_bundle after do_image_tar before do_image_complete

do_rootfs_wicenv[noexec] = "1"
do_image_ext4[noexec] = "1"
do_add_ostree_repo[noexec] = "1"
do_image_wic[noexec] = "1"
do_create_bundle[noexec] = "1"
