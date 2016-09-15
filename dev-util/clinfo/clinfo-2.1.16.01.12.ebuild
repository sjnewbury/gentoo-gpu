# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="A tool to display info about the system's OpenCL capabilities."
HOMEPAGE="https://github.com/Oblomov/clinfo"
SRC_URI="https://github.com/Oblomov/${PN}/archive/${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/ocl-icd"
RDEPEND="${DEPEND}"

src_install() {
	dobin ${WORKDIR}/${P}/${PN}
}
