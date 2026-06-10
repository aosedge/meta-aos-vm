SRC_URI:remove = " \
    file://0003-kuksa-client-Fix-AIO-version-of-gRPC-subscribe_target_values.patch;patchdir=.. \
"

SRCREV = "c27c66135fc3a8ac6cf9dac0a79a4fb249bdacdd"

# Add a user agent to avoid 403 errors from crates.io when fetching dependencies.
FETCHCMD_wget = "wget --user-agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64)'"

do_compile:prepend = ""

do_compile:prepend() {
    nativepython3 ${S}/prototagandcopy.py
    nativepython3 ${S}/protobuild.py
}
