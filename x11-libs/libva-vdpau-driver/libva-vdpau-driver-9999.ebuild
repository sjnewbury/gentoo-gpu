# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libva-vdpau-driver/libva-vdpau-driver-9999.ebuild,v 1.1 2012/11/21 17:53:31 aballier Exp $

EAPI=4

SCM=""
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SCM=git-r3
	EGIT_BRANCH=master
	EGIT_REPO_URI="git://anongit.freedesktop.org/vaapi/vdpau-driver"
fi

inherit autotools ${SCM} multilib-minimal

DESCRIPTION="VDPAU Backend for Video Acceleration (VA) API"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/vaapi"
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SRC_URI=""
else
	SRC_URI="http://www.freedesktop.org/software/vaapi/releases/libva-vdpau-driver/${P}.tar.bz2"
fi

LICENSE="GPL-2"
SLOT="0"
if [ "${PV%9999}" = "${PV}" ] ; then
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi
IUSE="debug opengl"

RDEPEND=">=x11-libs/libva-1.1.0[X,opengl?,${MULTILIB_USEDEP}]
	opengl? ( virtual/opengl[${MULTILIB_USEDEP}] )
	x11-libs/libvdpau[${MULTILIB_USEDEP}]
	!x11-libs/vdpau-video"

DEPEND="${DEPEND}
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-silent-rules \
		$(use_enable debug) \
		$(use_enable opengl glx)
}

multilib_src_install_all() {
	dodoc NEWS README AUTHORS
	find "${D}" -name '*.la' -delete
}
