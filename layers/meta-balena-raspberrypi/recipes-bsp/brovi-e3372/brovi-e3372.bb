FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

inherit systemd

DESCRIPTION = "Brovi switch to rcni mode at bootup"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI += "file://brovi-e3372.service \
            file://stick_startup.sh"

SYSTEMD_SERVICE:${PN} = "brovi-e3372.service"

RDEPENDS:${PN} = "bash systemd"

S = "${WORKDIR}"

do_install () {
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/brovi-e3372.service ${D}/${systemd_unitdir}/system/brovi-e3372.service
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/stick_startup.sh ${D}${bindir}
}

FILES:${PN} += " \
    ${bindir}/stick_startup.sh \
    "

COMPATIBLE_MACHINE = "(raspberrypi.*)"