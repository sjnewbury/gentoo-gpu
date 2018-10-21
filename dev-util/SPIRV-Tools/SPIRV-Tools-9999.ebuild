# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

inherit python-any-r1 cmake-multilib eapi7-ver

DESCRIPTION="GLSL reference compiler."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Tools"

if [[ "${PV}" == 9999* ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Tools"
	inherit git-r3
	KEYWORDS=
else
	SPIRV_HEADERS_V=3ce3e49d73b8abbf2ffe33f829f941fb2a40f552
	MY_PV=$(ver_cut 1)
	MY_REV=$(ver_cut 2)
	SRC_URI="
		https://github.com/KhronosGroup/SPIRV-Tools/archive/v${MY_PV}.${MY_REV}.tar.gz -> ${P}.tar.gz
		https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_HEADERS_V}.tar.gz -> SPIRV-Headers-${SPIRV_HEADERS_V}.tar.gz
	"
	KEYWORDS="~amd64"
fi

LICENSE="spirv-tools"
SLOT="0/${PV}"
IUSE=""

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

src_unpack() {
	if [[ "${PV}" == 9999* ]]; then
		git-r3_src_unpack
		git-r3_fetch "https://github.com/KhronosGroup/SPIRV-Headers.git" \
				"refs/heads/master"
		git-r3_checkout "https://github.com/KhronosGroup/SPIRV-Headers.git" \
				${S}/external/spirv-headers
	else
		unpack "${P}.tar.gz"
		cd ${S}/external
		unpack "SPIRV-Headers-${SPIRV_HEADERS_V}.tar.gz"
		mv "SPIRV-Headers-${SPIRV_HEADERS_V}" spirv-headers
	fi
}

src_prepare() {
	default

	if [[ "${PV}" == 9999* ]]; then
		# Stolen from vulkan-loader
		python ${FILESDIR}/external_revision_generator.py \
			${S} SPIRV_TOOLS_COMMIT_ID include/spirv-tools/spirv_tools_commit_id.h || die failed to generate commit_id header

		# Hack to install generated id header
		sed -i \
			-e '/linker\.hpp/a \${CMAKE_CURRENT_SOURCE_DIR}\/include\/spirv-tools\/spirv_tools_commit_id\.h' \
			CMakeLists.txt || die sed failed
	fi
}
