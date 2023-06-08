SUMMARY = "libvis layer"

PARENT_LAYER ?= "py-libs-layer"

require recipes-aos-layers/py-libs-layer/py-libs-layer.bb

LAYER_FEATURES:${PN} = " \
    libvis \
"

LAYER_VERSION = "1"
