DESCRIPTION = "An openGL-ES 2D library for OMAP3 SGX based systems"
LICENSE = "GPL"

DEPENDS = "virtual/libsdl libsdl-ttf libsdl-image libgles-omap3"

PR = "r7"

PARALLEL_MAKE = ""

SRC_URI = " \
  git://github.com/Cpasjuste/GLES2D.git;protocol=git;branch=master \
"

SRCREV = "758de1c91618cc8b4b2b3922c0c6c171b5a0b726"

S = "${WORKDIR}/git/src"

TARGET_CC_ARCH += "${LDFLAGS}"
TARGET_CFLAGS += "-Wall -I./include"

CFLAGS += "-D_PANDORA_"

do_compile_prepend() {
          cd ${S}/
}

do_compile() {
          oe_runmake 
          oe_runmake deploy
}

do_install() {
          install -d ${D}${libdir}/
          install -m 0644 ${S}/deployment/usr/lib/libGLES2D* ${D}${libdir}/

          install -d ${D}${includedir}/GLES2D
          install -m 0644 ${S}/deployment/usr/include/GLES2D/* ${D}${includedir}/GLES2D
}

FILES_${PN} += "${libdir}/libGLES2D.so*"
FILES_${PN}-dev += "${libdir}/libGLES2D.a ${includedir}/GLES2D/*"
