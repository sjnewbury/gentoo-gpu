# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 )

EGIT_REPO_URI="http://llvm.org/git/${PN}.git
	https://github.com/llvm-mirror/${PN}.git"
#EGIT_COMMIT="520743b0b72862a987ead6213dc1a5321a2010f9"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
else
	GIT_ECLASS="vcs-snapshot"
fi

inherit python-any-r1 ${GIT_ECLASS}

DESCRIPTION="OpenCL C library"
HOMEPAGE="http://libclc.llvm.org/"

if [[ ${PV} = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="https://github.com/llvm-mirror/libclc/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
		${SRC_PATCHES}"
fi

LICENSE="|| ( MIT BSD )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RADEON_CARDS="r600 radeon radeonsi"
VIDEO_CARDS="${RADEON_CARDS} nvidia"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} clang"

RDEPEND="
	video_cards_r600? ( >=sys-devel/llvm-3.9[llvm_targets_AMDGPU] )
	video_cards_radeon? ( >=sys-devel/llvm-3.9[llvm_targets_AMDGPU] )
	video_cards_radeonsi? ( >=sys-devel/llvm-3.9[llvm_targets_AMDGPU] )
	video_cards_nvidia? ( >=sys-devel/llvm-3.9[llvm_targets_NVPTX] )
	>=sys-devel/clang-3.9"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}"

REQUIRED_USE="|| ( video_cards_r600
		   video_cards_radeon
		   video_cards_radeonsi
		   video_cards_nvidia )
"

src_configure() {
	local targets=()
	local myconf=()

	use video_cards_radeonsi && \
		targets+=('amdgcn--')
	( use video_cards_radeon || use video_cards_r600 ) && \
		targets+=('r600--')
	use video_cards_nvidia && \
		targets+=('nvptx--nvidiacl' 'nvptx64--nvidiacl')

	myconf=(
		--with-llvm-config="$(type -P llvm-config)"
		--prefix="${EPREFIX}"/usr
	)

	use clang || myconf+=( --with-cxx-compiler="$(tc-getCXX)" )

	myconf+=( ${targets[@]} )

	./configure.py ${myconf[@]}
}

src_compile() {
	emake VERBOSE=1
}
