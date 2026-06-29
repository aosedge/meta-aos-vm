SUMMARY = "Open3D: A Modern Library for 3D Data Processing"
DESCRIPTION = "Open3D library and Python module installed from pre-built wheel"
HOMEPAGE = "http://www.open3d.org"
SECTION = "devel/python"
LICENSE = "MIT"

SRC_URI = " \
    https://github.com/isl-org/Open3D/releases/download/v0.19.0/open3d_cpu-0.19.0-cp312-cp312-manylinux_2_31_x86_64.whl;unpack=0 \
    https://raw.githubusercontent.com/isl-org/Open3D/v0.19.0/LICENSE;name=license \
"
SRC_URI[sha256sum] = "dc935427a28cdba4ef511e9ee366b6001962b583e64231887c9b2e4cff787ee2"
SRC_URI[license.sha256sum] = "e5439bd70250da5f17b3435ff9efb05e96e7f9fdc34248d3355b0026baadaa41"

LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=45ba986860b4cfd76b230975a71155aa"

inherit python_pep517 python3-dir

PEP517_WHEEL_PATH = "${WORKDIR}"

DEPENDS:append = " unzip-native"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    python_pep517_do_bootstrap_install
    rm -rf ${D}${PYTHON_SITEPACKAGES_DIR}/open3d-0.19.0.data
    rm -rf ${D}${PYTHON_SITEPACKAGES_DIR}/open3d/cuda
}

FILES:${PN} += "${PYTHON_SITEPACKAGES_DIR}"

INSANE_SKIP:${PN} += "already-stripped file-rdeps"
SKIP_FILEDEPS:${PN} = "1"

RDEPENDS:${PN} = " \
    python3-core \
    libx11 \
    libgl-mesa \
    libudev \
"
