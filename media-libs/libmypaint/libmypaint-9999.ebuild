# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit git-r3 toolchain-funcs scons-utils python-single-r1 multilib

EGIT_REPO_URI="https://github.com/mypaint/libmypaint.git"
DESCRIPTION="libmypaint, a.k.a. \"brushlib\", is a library for making brushstrokes which is used by MyPaint and other projects."
HOMEPAGE="http://mypaint.org"

SLOT="0"
LICENSE="ISC"

IUSE="introspection"

RDEPEND="dev-libs/json-c
	${PYTHON_DEPS}
	media-libs/babl media-libs/gegl:0.3[introspection?]
	introspection? ( dev-libs/gobject-introspection )"

DEPEND="${RDEPEND}
	sys-apps/sed"

src_prepare() {
	default
	# Fix multilib dir
	sed -i \
		-e "s/prefix\/lib/prefix\/$(get_libdir)/g" \
		-e "/LIBDIR/s/lib/$(get_libdir)/" \
		SConscript || die
}

src_configure() {
	MYSCONS=(
		CC="$(tc-getCC)"
		LD="$(tc-getLD)"
		CFLAGS="${CFLAGS}"
		LDFLAGS="${LDFLAGS}"
		enable_introspection="$(usex introspection)"
		enable_gegl="true"
		prefix=/usr
	)
}

src_compile() {
	escons -j1 "${MYSCONS[@]}"
}

src_install() {
	escons "${MYSCONS[@]}" --install-sandbox="${ED}" "${ED}"
}
