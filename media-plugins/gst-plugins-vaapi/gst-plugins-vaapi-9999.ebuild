# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI=https://github.com/01org/gstreamer-vaapi.git
#EGIT_REPO_URI=git://gitorious.org/vaapi/gstreamer-vaapi.git

inherit autotools autotools-utils git-r3

DESCRIPTION="GStreamer VA-API plugins"
HOMEPAGE="http://www.splitted-desktop.com/~gbeauchesne/gstreamer-vaapi/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="1.0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs opengl X drm wayland"

DEPEND="dev-libs/glib:2
	opengl? ( virtual/opengl )
	X? ( x11-libs/libX11 )
	drm? ( x11-libs/libdrm )
	wayland? ( dev-libs/wayland )
	>=media-libs/gstreamer-1.0.0
	>=media-libs/gst-plugins-base-1.0.0
	x11-libs/libva
	>=virtual/ffmpeg-0.6[vaapi]"

RDEPEND="${DEPEND}"

DOCS=(AUTHORS README NEWS)

pkg_setup() {
	# http://bugs.gentoo.org/show_bug.cgi?id=384585
	addpredict /usr/share/snmp/mibs/.index
	addpredict /var/lib/net-snmp/mib_indexes
}

src_prepare() {
	echo 'EXTRA_DIST =' > "${S}"/gtk-doc.make
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable opengl glx)
		$(use_enable X x11) 
		$(use_enable drm) 
		$(use_enable wayland) 
		--with-gstreamer-api=1.2
	)
	autotools-utils_src_configure
}
