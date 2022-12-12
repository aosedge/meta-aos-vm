AOS_IAM_CERT_MODULES = " \
    certhandler/modules/pkcs11module \
"

RDEPENDS_${PN} += " \
    aos-setupdisk \
    softhsm \
"

pkg_postinst_${PN}[noexec] = "1"
