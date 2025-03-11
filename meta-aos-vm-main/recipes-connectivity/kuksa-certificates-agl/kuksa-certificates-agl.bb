FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SUMMARY = "AGL certificates for KUKSA.val, the KUKSA Vehicle Abstraction Layer"
HOMEPAGE = "https://github.com/eclipse/kuksa.val"
BUGTRACKER = "https://github.com/eclipse/kuksa.val/issues"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"


SRC_URI = "file://CA.pem \
           file://Client.key \
           file://Client.pem \
           file://Server.key \
           file://Server.pem \
	       file://jwt.key.pub \
"

inherit allarch useradd

USERADD_PACKAGES = "${PN}-server"
USERADDEXTENSION = "useradd-staticids"
GROUPADD_PARAM:${PN}-server = "-g 900 kuksa ;"


do_install() {
    # Install replacement CA certificate, server key + certificate,
    # and client key + certificate.
    # These are AGL specific versions generated using a tweaked
    # genCerts.sh script to have different expiry dates than the
    # upstream defaults, and use AGL as the organization.
    install -d ${D}${sysconfdir}/kuksa-val/
    install -m 0644 ${WORKDIR}/CA.pem ${D}${sysconfdir}/kuksa-val/
    install -m 0640 -g 900 ${WORKDIR}/Server.key ${D}${sysconfdir}/kuksa-val/
    install -m 0640 -g 900 ${WORKDIR}/Server.pem ${D}${sysconfdir}/kuksa-val/
    install -m 0644 -g 900 ${WORKDIR}/jwt.key.pub ${D}${sysconfdir}/kuksa-val/
    install -m 0644 ${WORKDIR}/Client.key ${D}${sysconfdir}/kuksa-val/
    install -m 0644 ${WORKDIR}/Client.pem ${D}${sysconfdir}/kuksa-val/
}

PACKAGE_BEFORE_PN += "${PN}-ca ${PN}-server ${PN}-client"

FILES:${PN}-ca = " \
    ${sysconfdir}/kuksa-val/CA.pem \
"
RPROVIDES:${PN}-ca += "kuksa-val-certificates-ca"

FILES:${PN}-server = " \
    ${sysconfdir}/kuksa-val/Server.key \
    ${sysconfdir}/kuksa-val/Server.pem \
    ${sysconfdir}/kuksa-val/jwt.key.pub \
"
RPROVIDES:${PN}-server += "kuksa-val-certificates-server"
RDEPENDS:${PN}-server += "${PN}-ca"

FILES:${PN}-client = " \
    ${sysconfdir}/kuksa-val/Client.key \
    ${sysconfdir}/kuksa-val/Client.pem \
"
RPROVIDES:${PN}-client += "kuksa-val-certificates-client"
RDEPENDS:${PN}-client += "${PN}-ca"

ALLOW_EMPTY:${PN} = "1"

RDEPENDS:${PN} += "${PN}-ca ${PN}-server ${PN}-client"
