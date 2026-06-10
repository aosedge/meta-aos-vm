SRC_URI:remove = " \
    file://0003-kuksa-client-Fix-AIO-version-of-gRPC-subscribe_target_values.patch;patchdir=.. \
"

SRCREV = "c27c66135fc3a8ac6cf9dac0a79a4fb249bdacdd"

do_compile:prepend = ""

do_compile:prepend() {
    nativepython3 ${S}/prototagandcopy.py
    nativepython3 ${S}/protobuild.py
}
