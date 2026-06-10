DESCRIPTION = "KUKSA.val client"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

BRANCH = "main"
SRCREV = "c27c66135fc3a8ac6cf9dac0a79a4fb249bdacdd"

SRC_URI = "gitsm://github.com/eclipse-kuksa/kuksa-python-sdk.git;protocol=https;branch=${BRANCH}"

SRC_URI += " \
    file://0001-kuksa-client-Update-cmd2-completer-usage.patch;patchdir=.. \
    file://0002-kuksa-client-Tweak-grpcio-tools-requirement.patch;patchdir=.. \
"

S = "${WORKDIR}/git/kuksa-client"

inherit python_setuptools_build_meta

# Add a user agent to avoid 403 errors from crates.io when fetching dependencies.
FETCHCMD_wget = "wget --user-agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64)'"

do_compile:prepend() {
    nativepython3 ${S}/prototagandcopy.py
    nativepython3 ${S}/protobuild.py
}

DEPENDS = " \
    python3-setuptools-git-versioning-native \
    python3-grpcio-tools-native \
    python3-grpcio \
"

RDEPENDS:${PN} += " \
    python3-cmd2 \
    python3-importlib-metadata \
    python3-pkg-resources \
    python3-pygments \
    python3-websockets \
    python3-grpcio \
    python3-grpcio-tools \
    python3-jsonpath-ng \
"
