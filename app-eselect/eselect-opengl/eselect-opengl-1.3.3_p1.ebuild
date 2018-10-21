# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils multilib git-r3

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="https://www.gentoo.org/"

# Source:
# http://www.opengl.org/registry/api/glext.h
# http://www.opengl.org/registry/api/glxext.h
GLEXT="85"
GLXEXT="34"

MIRROR="https://dev.gentoo.org/~mattst88/distfiles"
SRC_URI=
EGIT_COMMIT=1add374a54da7cbbb0ec0c38b8d01555f05145c6
EGIT_REPO_URI=https://github.com/sjnewbury/opengl.eselect
#	${MIRROR}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND=">=app-admin/eselect-1.2.4
		 media-libs/mesa
		 !<x11-proto/glproto-1.4.17-r1
		 x11-base/xorg-server
		 !<x11-drivers/ati-drivers-14.9-r2
		 !=x11-drivers/ati-drivers-14.12
		 !<=app-emulation/emul-linux-x86-opengl-20140508"

#S=${WORKDIR}

pkg_preinst() {
	# we may be moving the config file, so get it early
	OLD_IMPL=$(eselect opengl show)
}

pkg_postinst() {
	local shopt_save=$(shopt -p nullglob)
	shopt -s nullglob
	local opengl_dirs=( "${EROOT}"/usr/lib*/opengl )
	${shopt_save}
	if [[ -n ${opengl_dirs[@]} ]]; then
		# delete broken symlinks
		find "${EROOT}"/usr/lib*/opengl -xtype l -delete
		# delete empty leftover directories (they confuse eselect)
		find "${EROOT}"/usr/lib*/opengl -depth -type d -empty -exec rmdir -v {} +
	fi

	if [[ -n "${OLD_IMPL}" && "${OLD_IMPL}" != '(none)' ]] ; then
		eselect opengl set "${OLD_IMPL}"
	fi
	if [[ -f ${EROOT}/etc/env.d/000opengl ]]; then
		# remove the new unforked file, restored original
		rm -vf "${EROOT}"/etc/env.d/000opengl
	fi
}

src_prepare() {
	# don't die on Darwin users
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/libGL\.so/libGL.dylib/' opengl.eselect || die
	fi
}

src_install() {
	insinto "/usr/share/eselect/modules"
	doins opengl.eselect
	doman opengl.eselect.5
}
