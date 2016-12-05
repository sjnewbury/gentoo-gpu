# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

#PATCH_VER="1.1"
#UCLIBC_VER="1.0"
gcc_LIVE_BRANCH="master"

inherit toolchain

KEYWORDS=""

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	>=${CATEGORY}/binutils-2.20"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_prepare() {
	epatch	"${FILESDIR}/nvptx-no-libffi.patch" \
		"${FILESDIR}/nvptx-no-boehm-gc.patch"

	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi
	is_crosscompile && EPATCH_EXCLUDE+=" 05_all_gcc-spec-env.patch"

	toolchain_src_prepare
}
