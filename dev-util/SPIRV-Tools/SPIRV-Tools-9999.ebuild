# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

inherit python-any-r1 cmake-multilib

DESCRIPTION="GLSL reference compiler."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Tools"

if [[ "${PV}" == 9999* ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Tools"
	inherit git-r3
	KEYWORDS=
else
	MY_PV=$(get_version_component_range 1-2)
	MY_REV=$(get_version_component_range 3)
	SRC_URI="https://github.com/KhronosGroup/SPIRV-Tools/archive/spirv-${MY_PV}-rev${MY_REV:1}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="spirv-tools"
SLOT="0/${PV}"
IUSE=""

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

if [[ "${PV}" != 9999* ]]; then
	S="${WORKDIR}/${PN}-spirv-${MY_PV}-rev${MY_REV:1}"
fi

if [[ "${PV}" == 9999* ]]; then
	src_unpack() {
		git-r3_src_unpack
		git-r3_fetch "https://github.com/KhronosGroup/SPIRV-Headers.git" \
				"refs/heads/master"
		git-r3_checkout "https://github.com/KhronosGroup/SPIRV-Headers.git" \
				${S}/external/spirv-headers
	}
fi

src_prepare() {
	default

	# Stolen from vulkan-loader
	python ${FILESDIR}/external_revision_generator.py \
		${S} SPIRV_TOOLS_COMMIT_ID include/spirv-tools/spirv_tools_commit_id.h || die failed to generate commit_id header

	# Hack to install generated id header
	sed -i \
		-e '/linker\.hpp/a \${CMAKE_CURRENT_SOURCE_DIR}\/include\/spirv-tools\/spirv_tools_commit_id\.h' \
		CMakeLists.txt || die sed failed
}
