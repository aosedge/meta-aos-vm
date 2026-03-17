PKCS11_PIN_PATH ?= "file:/var/aos/iam/.usrpin"

do_install:append:class-target() {
    echo  "pkcs11-module-token-pin = ${PKCS11_PIN_PATH}" >> ${D}${sysconfdir}/ssl/openssl-aos.cnf
}
