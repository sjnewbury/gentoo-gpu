# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-multilib

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
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

if [[ "${PV}" != 9999* ]]; then
	S="${WORKDIR}/${PN}-spirv-${MY_PV}-rev${MY_REV:1}"
fi

PATCHES=( "${FILESDIR}/fix-multilib-${PV}.patch" )

if [[ "${PV}" == 9999* ]]; then
	src_unpack() {
		git-r3_src_unpack
		git-r3_fetch "https://github.com/KhronosGroup/SPIRV-Headers.git" \
				"refs/heads/master"
		git-r3_checkout "https://github.com/KhronosGroup/SPIRV-Headers.git" \
				${S}/external/spirv-headers
	}
fi
