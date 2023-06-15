AOS_IAM_CERT_MODULES = " \
    certhandler/modules/pkcs11module \
"

RDEPENDS:${PN} += " \
    aos-setupdisk \
    softhsm \
"
