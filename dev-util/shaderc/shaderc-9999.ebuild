# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/google/shaderc.git"
	inherit git-r3
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/google/shaderc/archive/ndk-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/shaderc-ndk-${PV}"
fi

inherit cmake-multilib

DESCRIPTION="A collection of tools, libraries and tests for shader compilation."
HOMEPAGE="https://github.com/google/shaderc"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${PYTHON_DEPS}
	dev-util/glslang:=
	dev-util/SPIRV-Tools:=[${MULTILIB_USEDEP}]"

src_prepare() {
	cmake-utils_src_prepare
	sed -i \
		-e '/third_party/d' \
		-e '/build-version/,/COMMENT/d' \
		CMakeLists.txt || die sed failed

	# Create build-version.inc since we want to use our packaged
	# SPIRV-Tools and glslang
	echo \"shaderc $(grep -m1 -o '^v[[:digit:]]\{4\}\.[[:digit:]]\(-dev\)\?' CHANGES) $(git describe)\" \
		> glslc/src/build-version.inc
	echo \"spirv-tools $(grep -m1 -o '^v[[:digit:]]\{4\}\.[[:digit:]]\(-dev\)\?' /usr/share/doc/SPIRV-Tools-*/CHANGES) $(grep -o '[[:xdigit:]]\{40\}' /usr/include/spirv-tools/spirv_tools_commit_id.h)\" \
		>> glslc/src/build-version.inc
	echo \"glslang \'\'\" >> glslc/src/build-version.inc

	default
}

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=True
		-DSHADERC_SKIP_TESTS=True
		-DCMAKE_C_FLAGS="${CFLAGS}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
		-DCMAKE_LD_FLAGS="${LDFLAGS}"
	)
	cmake-utils_src_configure
}
