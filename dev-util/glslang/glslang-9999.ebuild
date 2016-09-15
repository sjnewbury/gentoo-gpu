# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION="GLSL reference compiler."
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/KhronosGroup/glslang"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	# Match SPIRV-Tools
	insinto /usr/include/SPIRV
	doins SPIRV/spirv.hpp

	cmake-utils_src_install
}
