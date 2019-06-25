# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="GLSL reference compiler."
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/"

if [[ "${PV}" == 9999* ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/KhronosGroup/glslang"
	inherit git-r3
else
	RELEASE_NAME="Overload400-PrecQual"
	SRC_URI=""https://github.com/KhronosGroup/glslang"/archive/${RELEASE_NAME}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	# Match SPIRV-Tools
	insinto /usr/include/SPIRV
	doins SPIRV/spirv.hpp

	cmake-utils_src_install
}
