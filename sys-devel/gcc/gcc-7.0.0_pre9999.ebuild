# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

#PATCH_VER="1.0"
#UCLIBC_VER="1.0"
gcc_LIVE_BRANCH="master"

# Hardened gcc 4 stuff
#PIE_VER="0.6.5"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
#PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
#PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
#end Hardened stuff

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
	# Offload Acceleration patches
	epatch 	"${FILESDIR}/0001-nvptx-msoft-stack.patch" \
		"${FILESDIR}/0002-nvptx-implement-predicated-instructions.patch" \
		"${FILESDIR}/0003-nvptx-muniform-simt.patch" \
		"${FILESDIR}/0004-nvptx-mgomp.patch" \
		"${FILESDIR}/0005-nvptx-mkoffload-pass-mgomp-for-OpenMP-offloading.patch" \
		"${FILESDIR}/0006-new-target-hook-TARGET_SIMT_VF.patch" \
		"${FILESDIR}/0007-nvptx-backend-new-insns-for-OpenMP-SIMD-via-SIMT.patch" \
		"${FILESDIR}/0008-nvptx-handle-OpenMP-omp-target-entrypoint.patch" \
		"${FILESDIR}/nvptx-no-libffi.patch" \
		"${FILESDIR}/nvptx-no-boehm-gc.patch"

	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi
	is_crosscompile && EPATCH_EXCLUDE+=" 05_all_gcc-spec-env.patch"

	toolchain_src_prepare
}
