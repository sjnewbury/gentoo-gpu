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

multilib_src_install() {
	local GL_ROOT="/usr/$(get_libdir)/opengl/glvnd/lib"
	emake DESTDIR="${D}" install
	dodir "${GL_ROOT}"
	mv -f "${ED}"/usr/$(get_libdir)/lib{GL,GLESv1_CM,GLESv2,GLX,OpenGL}* \
		"${ED}"${GL_ROOT}/
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
}
