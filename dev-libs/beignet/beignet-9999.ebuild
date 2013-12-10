# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )
inherit python-single-r1 cmake-utils eutils git-2

DESCRIPTION="Beignet is an open source implementaion of OpenCL on Intel GPUs"
HOMEPAGE="https://github.com/karolherbst/beignet"
SRC_URI=""
#EGIT_REPO_URI="https://github.com/karolherbst/beignet.git"
EGIT_REPO_URI="git://anongit.freedesktop.org/beignet"
#EGIT_BRANCH="changes"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="x11-libs/libdrm[video_cards_intel]
	 >=sys-devel/llvm-3.3[clang]
	 app-admin/eselect-opencl"
DEPEND="${PYTHON_DEPS}
     ${RDEPEND}"

src_prepare() {
	cmake-utils_src_prepare

	# Fix linking
	epatch "${FILESDIR}"/"${P}"-respect-flags.patch
	epatch "${FILESDIR}"/"${P}"-libOpenCL.patch
#	epatch "${FILESDIR}"/"${P}"-llvm33.patch
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	insinto /usr/$(get_libdir)/OpenCL/vendors/${PN}/include/CL
	doins ${S}/include/CL/*
#        for i in "${S}"/include/CL/*; do
#                if [[ -e $i ]]; then
#                        doins $i
#                fi
#        done
}

pkg_postinst() {
	# Switch to the beignet implementation.
	echo
	eselect opencl set --use-old ${PN}

	# switch to beignet and back if necessary, bug #374647 comment 11
	OLD_IMPLEM="$(eselect opencl show)"
	if [[ ${PN}x != ${OLD_IMPLEM}x ]]; then
		eselect opencl set ${PN}
		eselect opencl set ${OLD_IMPLEM}
	fi
}
