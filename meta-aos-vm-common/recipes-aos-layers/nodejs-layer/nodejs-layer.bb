SUMMARY = "nodejs layer"

require recipes-aos-layers/base-layer/base-layer.inc

LAYER_FEATURES:${PN} = " \
    nodejs \
"

LAYER_VERSION = "1"
