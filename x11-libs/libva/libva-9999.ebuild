# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libva/libva-9999.ebuild,v 1.18 2013/06/29 03:43:38 aballier Exp $

EAPI=6

SCM=""
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SCM=git-r3
	EGIT_REPO_URI="https://github.com/intel/libva.git"
fi

inherit autotools ${SCM} multilib multilib-minimal

DESCRIPTION="Video Acceleration (VA) API for Linux"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/vaapi"
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SRC_URI=""
else
	SRC_URI="http://www.freedesktop.org/software/vaapi/releases/libva/${P}.tar.bz2"
fi

LICENSE="MIT"
SLOT="0/9999"
if [ "${PV%9999}" = "${PV}" ] ; then
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
else
	KEYWORDS=""
fi
IUSE="+drm opengl vdpau wayland X"
REQUIRED_USE="|| ( drm wayland X )"

VIDEO_CARDS="nvidia intel fglrx"
for x in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${x}"
done

RDEPEND=">=x11-libs/libdrm-2.4[${MULTILIB_USEDEP}]
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libxcb[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
	)
	media-libs/mesa[${MULTILIB_USEDEP}]
	opengl? ( virtual/opengl[${MULTILIB_USEDEP}] )
	wayland? ( >=dev-libs/wayland-1[${MULTILIB_USEDEP}] )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"
PDEPEND="video_cards_nvidia? ( x11-libs/libva-vdpau-driver[${MULTILIB_USEDEP}] )
	vdpau? ( x11-libs/libva-vdpau-driver[${MULTILIB_USEDEP}] )
	video_cards_fglrx? ( x11-libs/xvba-video[${MULTILIB_USEDEP}] )
	video_cards_intel? ( >=x11-libs/libva-intel-driver-1.0.18[${MULTILIB_USEDEP}] )
	"

REQUIRED_USE="opengl? ( || ( wayland X ) )"

ECONF_SOURCE="${S}"

PATCHES=(
#	"${FILESDIR}/0001-DRI3-Enable-core-DRI3-protocol-support.patch"
#	"${FILESDIR}/0002-DRI3-Plugging-DRI3-support-for-libva.patch"
#	"${FILESDIR}/0003-DRI3-Add-Present-Extension-support.patch"
#	"${FILESDIR}/0004-DRI3-Mark-DRI3-dependent-on-Present.patch"
#	"${FILESDIR}/libva-dri3-reserved.patch"
)

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	myconf="\
		--disable-silent-rules
		--with-drivers-path="${EPREFIX}/usr/$(get_libdir)/va/drivers"
		$(use_enable opengl glx)
		$(use_enable X x11)
		$(use_enable X dri3)
		$(use_enable wayland)
		$(use_enable drm)
		"
	econf ${myconf}
}

multilib_src_compile() {
	ln -s "${S}"/va/libva.syms va/libva.syms
	default
}

multilib_src_install() {
	emake DESTDIR="${D}" install || die
}

multilib_src_install_all() {
	dodoc NEWS || die
	find "${D}" -name '*.la' -delete
}
