# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-multilib

DESCRIPTION="GLSL reference compiler."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Tools"
SRC_URI=""
EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Tools"

LICENSE="spirv-tools"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/fix-multilib.patch" )

src_unpack() {
	git-r3_src_unpack
	git-r3_fetch "https://github.com/KhronosGroup/SPIRV-Headers.git" \
			"refs/heads/master"
	git-r3_checkout "https://github.com/KhronosGroup/SPIRV-Headers.git" \
			${S}/external/spirv-headers
}
