SUMMARY = "A very basic Wayland image with AOS components"

require aos-image-minimal.bb

DISTRO_FEATURES += "wayland splash"
CORE_IMAGE_EXTRA_INSTALL += "wayland"

IMAGE_INSTALL += "weston \
                  weston-examples \
                  "
                 
