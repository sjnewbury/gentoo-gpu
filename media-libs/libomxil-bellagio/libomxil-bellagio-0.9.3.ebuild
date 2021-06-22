# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal

DESCRIPTION="Open Source implementation of the OpenMAX Integration Layer"
HOMEPAGE="http://omxil.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN:3:5}/${P}.tar.gz mirror://ubuntu/pool/universe/${PN:0:4}/${PN}/${PN}_${PV}-1ubuntu2.debian.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+audioeffects +clocksrc debug doc +videoscheduler"

RDEPEND=""
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
"

PATCHES=(
	"${FILESDIR}"/${P}-dynamicloader-linking.patch
	"${FILESDIR}"/${P}-parallel-build.patch
	"${FILESDIR}"/${P}-version.patch
	"${FILESDIR}"/${P}-gcc5.patch
)

ECONF_SOURCE="${S}"

src_prepare() {
	default
	eapply "${WORKDIR}"/debian/patches/*.patch
	eautoreconf
}

multilib_src_configure() {
	econfargs=(
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		$(use_enable audioeffects)
		$(use_enable clocksrc)
		$(use_enable debug)
		$(use_enable doc)
		$(use_enable videoscheduler)
	)
	econf "${econf_args[@]}"
}
