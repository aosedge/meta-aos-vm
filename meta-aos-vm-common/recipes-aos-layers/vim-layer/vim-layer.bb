SUMMARY = "vim layer"

require recipes-aos-layers/base-layer/base-layer.inc

LAYER_FEATURES_${PN} = " \
    vim \
"

LAYER_WHITEOUTS_${PN} = " \
    /var/cache/fontconfig \
    /usr/share/fontconfig/* \
    /usr/share/applications/gvim.desktop \
    /usr/share/applications/vim.desktop \
"

LAYER_VERSION = "1"
