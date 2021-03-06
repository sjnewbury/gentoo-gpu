# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils eutils multilib toolchain-funcs

DESCRIPTION="A set of cuda-enabled texture tools and compressors"
HOMEPAGE="http://developer.nvidia.com/object/texture_tools.html"
SRC_URI="https://${PN}.googlecode.com/files/${P}-1.tar.gz
	https://dev.gentoo.org/~ssuominen/${P}-patchset-1.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cg cuda glew glut openexr"

RDEPEND="media-libs/libpng:0=
	media-libs/ilmbase:=
	media-libs/tiff:0
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	x11-libs/libX11
	cg? ( media-gfx/nvidia-cg-toolkit )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	glew? ( media-libs/glew:0= )
	glut? ( media-libs/freeglut )
	openexr? ( media-libs/openexr:= )
	"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-cg.patch" # fix bug #414509
	"${FILESDIR}/${P}-gcc-4.7.patch" # fix bug #423965
	"${FILESDIR}/${P}-openexr.patch" # fix bug #462494
	"${FILESDIR}/${P}-clang.patch" # fix clang build
	"${FILESDIR}/${P}-cpp14.patch" # fix bug #594938
)

S="${WORKDIR}/${PN}"

pkg_setup() {
	if use cuda; then
		if [[ $(( $(gcc-major-version) * 10 + $(gcc-minor-version) )) -gt 50 ]] ; then
			eerror "gcc 5.0 and up are not supported for useflag cuda!"
			die "gcc 5.0 and up are not supported for useflag cuda!"
		fi
	fi
}

src_prepare() {
	edos2unix cmake/*
	sed -i \
		-e "/^SET(CUDA_OPTIONS/c\SET(CUDA_OPTIONS \"--host-compilation=C\" \"--compiler-bindir=/usr/${CHOST}/gcc-bin/$(gcc-fullversion)\")" \
		cmake/FindCUDA.cmake || die sed failed
	EPATCH_SUFFIX=patch epatch "${WORKDIR}/patches"
	cmake-utils_src_prepare

}

src_configure() {
	local mycmakeargs=(
		-DLIBDIR=$(get_libdir)
		-DNVTT_SHARED=TRUE
		-DCG=$(usex cg)
		-DCUDA=$(usex cuda)
		-DGLEW=$(usex glew)
		-DGLUT=$(usex glut)
		-DOPENEXR=$(usex openexr)
	)
	cmake-utils_src_configure
}
