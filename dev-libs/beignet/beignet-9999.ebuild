# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=5
inherit cmake-utils eutils git-2

DESCRIPTION="Beignet is an open source implementaion of OpenCL on Intel GPUs"
HOMEPAGE="https://github.com/karolherbst/beignet"
SRC_URI=""
EGIT_REPO_URI="https://github.com/karolherbst/beignet.git"
EGIT_BRANCH="changes"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="x11-libs/libdrm[video_cards_intel]
	 =sys-devel/llvm-9999"
DEPEND="${RDEPEND}"

src_prepare() {
	cmake-utils_src_prepare

	# Fix linking
	epatch "${FILESDIR}"/"${P}"-gbe-lflags.patch
	epatch "${FILESDIR}"/"${P}"-llvm-lflags.patch
	epatch "${FILESDIR}"/"${P}"-libinstalldir.patch

	# TargetData has moved
	sed -i -e 's:llvm/Target/TargetData.h:llvm/DataLayout.h:' \
		backend/src/llvm/llvm_passes.cpp \
		backend/src/llvm/llvm_gen_backend.cpp || die

}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR=/usr/$(get_libdir)
	)

	cmake-utils_src_configure
}