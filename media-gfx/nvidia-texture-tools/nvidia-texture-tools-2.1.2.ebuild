# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="A set of cuda-enabled texture tools and compressors"
HOMEPAGE="https://github.com/castano/nvidia-texture-tools"
SRC_URI="https://github.com/castano/nvidia-texture-tools/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 -riscv ~x86"
IUSE="cpu_flags_x86_sse2 openmp"

RDEPEND="
	media-libs/ilmbase:=
	media-libs/libpng:0=
	media-libs/tiff:0
	sys-libs/zlib
	virtual/jpeg:0
	x11-libs/libX11
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-cmake.patch
	"${FILESDIR}"/${P}-test_path.patch
	)
DOCS=( ChangeLog README.md )

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	# May be able to restore CUDA, but needs an old gcc
	local mycmakeargs=(
		-DCUDA_FOUND=OFF
		-DGCONFTOOL2=OFF
		-DNVTT_SHARED=0
		-DBUILD_SQUISH_WITH_OPENMP=$(usex openmp)
		-DBUILD_SQUISH_WITH_SSE2=$(usex cpu_flags_x86_sse2)
	)
	cmake_src_configure
}
