SUMMARY = "python libs layer"

require recipes-aos-layers/base-layer/base-layer.inc

LAYER_FEATURES_${PN} = " \
    python3-compression \
    python3-crypt \
    python3-json \
    python3-misc \
    python3-shell \
    python3-six \
    python3-threading \
    python3-websocket-client \
"

LAYER_VERSION = "1"
