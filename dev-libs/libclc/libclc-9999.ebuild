# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 python3_4 python3_5 python3_6 )

EGIT_REPO_URI="http://llvm.org/git/${PN}.git
	https://github.com/llvm-mirror/${PN}.git"
#EGIT_COMMIT="520743b0b72862a987ead6213dc1a5321a2010f9"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
else
	GIT_ECLASS="vcs-snapshot"
fi

inherit llvm prefix python-any-r1 toolchain-funcs ${GIT_ECLASS}

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
RADEON_CARDS="r600 radeonsi"
VIDEO_CARDS="${RADEON_CARDS} nvidia"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} clang"

RDEPEND="
	video_cards_r600? ( >=sys-devel/llvm-3.9[llvm_targets_AMDGPU] )
	video_cards_radeonsi? ( >=sys-devel/llvm-3.9[llvm_targets_AMDGPU] )
	video_cards_nvidia? ( >=sys-devel/llvm-3.9[llvm_targets_NVPTX] )
	>=sys-devel/clang-3.9"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}"

REQUIRED_USE="|| ( ${IUSE_VIDEO_CARDS} )"

src_prepare() {
	default
	if use prefix; then
		hprefixify configure.py
	fi
}

pkg_setup() {
	# we do not need llvm_pkg_setup
	python-any-r1_pkg_setup
}

src_configure() {
	local libclc_targets=()
	local myconf=()


	use video_cards_nvidia && libclc_targets+=("nvptx--" "nvptx64--" "nvptx--nvidiacl" "nvptx64--nvidiacl")
	use video_cards_r600 && libclc_targets+=("r600--")
	use video_cards_radeonsi && libclc_targets+=("amdgcn--" "amdgcn-mesa-mesa3d" "amdgcn--amdhsa")

	[[ ${#libclc_targets[@]} ]] || die "libclc target missing!"

	myconf=(--with-llvm-config="$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin/llvm-config"
		--prefix="${EPREFIX}/usr" )

	use clang || myconf+=( --with-cxx-compiler="$(tc-getCXX)" )

	myconf+=( "${libclc_targets[@]}" )

	./configure.py ${myconf[@]} || die
}

src_compile() {
	emake VERBOSE=1
}
