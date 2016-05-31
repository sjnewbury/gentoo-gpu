# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit autotools-multilib git-r3 python-single-r1

EGIT_REPO_URI="https://github.com/NVIDIA/libglvnd.git"

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://github.com/NVIDIA/libglvnd"
SLOT=0

LICENSE="GPL"

RDEPEND="x11-base/xorg-server
	x11-libs/libX11
	x11-libs/libXext"

DEPEND="${RDEPEND}
	${PYTHON_DEPS}"

src_prepare() {
	default
	epatch_user
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf --libdir=/usr/$(get_libdir)/opengl/glvnd/lib
}

multilib_src_install() {
	local GL_ROOT="/usr/$(get_libdir)/opengl/glvnd/lib"
	emake DESTDIR="${D}" install
#	mv -f "${ED}"${GL_ROOT}/xorg \
#		"${ED}"/usr/$(get_libdir) || die mv failed
	mv -f "${ED}"${GL_ROOT}/pkgconfig \
		"${ED}"/usr/$(get_libdir) || die mv failed
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
}
