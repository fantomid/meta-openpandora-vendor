DESCRIPTION = "OpenPandora PMenu launcher"
LICENSE = "GPL"

DEPENDS = "virtual/libsdl libgles-omap3 libgles2d pandora-libpnd libconfig"

PR = "r11"

PARALLEL_MAKE = ""

SRC_URI = " \
  git://github.com/Cpasjuste/pmenu.git;protocol=git;branch=master \
  file://0001-Remove-libconfig-from-Makefile.patch;patch=1 \
"

SRCREV = "ba590077b168f25b3d18e31c5efc644846ff53ee"

S = "${WORKDIR}/git"

export PNDSDK="${STAGING_DIR}"

TARGET_CC_ARCH += "${LDFLAGS}"
TARGET_CFLAGS += "-Wall -I./include"

do_compile_prepend() {
          cd ${S}/
}

do_compile() {
          oe_runmake 
          oe_runmake deploy
}

do_install() {
          install -d ${D}${sysconfdir}/pandora/pmenu/
          install -m 0644 ${S}/deployment/etc/pandora/pmenu/pmenu.cfg ${D}${sysconfdir}/pandora/pmenu/pmenu.cfg
          
##          for i in $(ls -d ${S}/deployment/etc/pandora/pmenu/skins/*/); 
#          do install -d ${D}${sysconfdir}/pandora/pmenu/skins/${i%%/};install -m 0644 ${S}/deployment/etc/pandora/pmenu/skins/${i%%/}/* ${D}${sysconfdir}/pandora/pmenu/skins/${i%%/}
#          done
          
          
         # for i in `ls ${S}/deployment/etc/pandora/pmenu/skins/`
	 # do
	 #   if [ -d ${S}/deployment/etc/pandora/pmenu/skins/$i ]
	 #   then
	 #   echo  $i
	 # fi
          
          install -d ${D}${sysconfdir}/pandora/pmenu/skins/NewSkin
	  install -m 0644 ${S}/deployment/etc/pandora/pmenu/skins/NewSkin/* ${D}${sysconfdir}/pandora/pmenu/skins/NewSkin

          install -d ${D}${sysconfdir}/pandora/pmenu/skins/Platinum
	  install -m 0644 ${S}/deployment/etc/pandora/pmenu/skins/Platinum/* ${D}${sysconfdir}/pandora/pmenu/skins/Platinum

          install -d ${D}${bindir}/
          install -m 0755 ${S}/deployment/etc/pandora/pmenu/pmenu ${D}${bindir}/pmenu
}

FILES_${PN} += "${bindir} ${sysconfdir}"
