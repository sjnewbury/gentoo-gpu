# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils versionator

DESCRIPTION="GLSL reference compiler."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Tools"
MY_PV=$(get_version_component_range 1-2)
MY_REV=$(get_version_component_range 3)
SRC_URI="https://github.com/KhronosGroup/SPIRV-Tools/archive/spirv-${MY_PV}-rev${MY_REV:1}.tar.gz"

LICENSE="spirv-tools"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-spirv-${MY_PV}-rev${MY_REV:1}"
