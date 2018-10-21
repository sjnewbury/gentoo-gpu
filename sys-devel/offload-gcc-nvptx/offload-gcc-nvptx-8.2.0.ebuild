# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCH_VER="1.4"
#UCLIBC_VER="1.0"
NEWLIBV=3.0.0.20180831

CTARGET=nvptx-none
TOOLCHAIN_ALLOWED_LANGS="c c++ jit fortran"

inherit toolchain

KEYWORDS=""

RDEPEND=""
DEPEND="${RDEPEND}
	sys-devel/nvptx-tools"

src_prepare() {
	epatch	"${FILESDIR}/nvptx-no-libffi.patch" \
		"${FILESDIR}/nvptx-no-boehm-gc.patch"

	EPATCH_EXCLUDE+=" 05_all_gcc-spec-env.patch 10_all_default-fortify-source.patch"

	toolchain_src_prepare
}
